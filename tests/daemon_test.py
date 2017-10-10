import json
import threading
import time
import os

import pytest

from tuxeatpi_hotword_kittai.daemon import HotWord
from tuxeatpi_hotword_kittai.daemon import HotWordError
from tuxeatpi_common.message import Message


class TestBrain(object):

    @classmethod
    def setup_class(self):
        workdir = "tests/workdir"
        intents = "intents"
        dialogs = "dialogs"
        self.hotword = HotWord("hotword", workdir, intents, dialogs)
        self.t = threading.Thread(target=self.hotword.start)

    @classmethod
    def teardown_class(self):
        self.hotword.settings.delete("/config/global")
        self.hotword.settings.delete("/config/fakecomponent")
        self.hotword.settings.delete()
        self.hotword.registry.clear()
        try:  # CircleCI specific
            self.hotword.shutdown()
        except AttributeError:
            pass
        print(self.t.is_alive())
#        self.t.join()

    @pytest.mark.order1
    def test_hotword(self, capsys):
        # --help

        self.tt = self.t.start()

        time.sleep(1)
        global_config = {"language": "en_US",
                         "nlu_engine": "fake_nlu",
                         }
        self.hotword.settings.save(global_config, "global")
        config = {"model_file": "Coco.pmdl",
                  "sensitivity": 0.45,
                  "sound_file": "sounds/answer.wav",
                  }
        self.hotword.settings.save(config)
        self.hotword.set_config(config)
        time.sleep(3)
        assert self.hotword._answer_sound_path == "sounds/answer.wav"
        assert self.hotword._model_file == "Coco.pmdl"
        assert self.hotword.sensitivity == 0.45
        assert self.hotword.detector is not None
        time.sleep(1)

        return
        self.hotword.disable()
        assert self.hotword.disabled == True

        self.hotword.enable()
        assert self.hotword.disabled == False

        # Improve this test for circleCI
        if not os.environ.get('CIRCLECI'):
            self.hotword._answering()
