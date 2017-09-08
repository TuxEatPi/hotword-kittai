FROM tuxeatpi/pulseaudio

COPY dialogs /dialogs
COPY intents /intents

COPY test_requirements.txt /opt/test_requirements.txt
COPY requirements.txt /opt/requirements.txt

COPY Makefile /opt/Makefile
RUN mkdir -p /workdir /opt/tuxeatpi_hotword_kittai/libs && \
    apt-get update && \
    apt-get install -y --no-install-recommends libatlas3-base libportaudio2 swig g++ portaudio19-dev libatlas-base-dev && \
    apt-get clean && \
    sed -i 's/.*python-aio-etcd.*//' /opt/requirements.txt && \
    sed -i 's/.*tuxeatpi-common.*//' /opt/requirements.txt && \
    pip install -r /opt/requirements.txt && \
    cd /opt && make dev-build-snowboy  && \
    apt-get -y purge g++ portaudio19-dev libatlas-base-dev && apt -y autoremove --purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /opt/Makefile

COPY setup.py /opt/setup.py
COPY tuxeatpi_hotword_kittai /opt/tuxeatpi_hotword_kittai
RUN cd /opt && python setup.py install

CMD ["hotword-kittai"]
