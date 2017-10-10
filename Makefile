#######################################
### Dev targets
#######################################
dev-dep:
	sudo apt-get install python3-virtualenv  musl-dev portaudio19-dev make swig g++

dev-build-snowboy:
	git clone https://github.com/Kitt-AI/snowboy.git || true
	cd snowboy && git pull
	cd snowboy/swig/Python3/ && make
	cp snowboy/swig/Python3/snowboydetect.py snowboy/swig/Python3/_snowboydetect.so tuxeatpi_hotword_kittai/libs/
	mkdir -p tuxeatpi_hotword_kittai/libs/resources
	cp snowboy/resources/common.res tuxeatpi_hotword_kittai/libs/resources/
	rm -rf snowboy

dev-pyenv:
	virtualenv -p /usr/bin/python3 env
	env/bin/pip3 install -r requirements.txt --upgrade --force-reinstall
	env/bin/python setup.py develop

#######################################
### Docker
#######################################

docker_build:
	docker build -t hotword_kittai -f Dockerfile .

docker_run:
	docker run --rm --net=host \
    -e TEP_ETCD_HOST=127.0.0.1 \
    -e TEP_MQTT_HOST=127.0.0.1 \
    -v `pwd`/Coco.pmdl:/Coco.pmdl \
    -v `pwd`/sounds/answer.wav:/hotword_answer.wav \
    -v /run/user/`id -u`/pulse:/run/pulse:ro \
    hotword_kittai tep

#######################################
### Documentation
#######################################
doc-update-refs:
	rm -rf doc/source/refs/
	sphinx-apidoc -M -f -e -o doc/source/refs/ tuxeatpi_hotword_kittai

doc-generate:
	cd doc && make html
	touch doc/build/html/.nojekyll

#######################################
### Test targets
#######################################

test-run: test-syntax test-pytest

test-syntax:
	env/bin/pycodestyle --max-line-length=100 --exclude snowboydetect.py tuxeatpi_hotword_kittai
	env/bin/pylint --rcfile=.pylintrc -r no --ignore=snowboydetect.py tuxeatpi_hotword_kittai

test-pytest:
	rm -rf .coverage nosetest.xml nosetests.html htmlcov
	env/bin/pytest --html=pytest/report.html --self-contained-html --junit-xml=pytest/junit.xml --cov=tuxeatpi_hotword_kittai/ --cov-report=term --cov-report=html:pytest/coverage/html --cov-report=xml:pytest/coverage/coverage.xml -p no:pytest_wampy tests 
	coverage combine || true
	coverage report --include='*/tuxeatpi_hotword_kittai/*'
	# CODECLIMATE_REPO_TOKEN=${CODECLIMATE_REPO_TOKEN} codeclimate-test-reporter

