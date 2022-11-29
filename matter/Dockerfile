FROM buildpack-deps:bullseye AS builder
WORKDIR /src/
RUN apt-get update \
&& apt-get install -y -qq git gcc g++ pkg-config libssl-dev libdbus-1-dev \
libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev \
ca-certificates curl gnupg lsb-release wget conntrack python-is-python3 avahi-daemon \
build-essential libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
&& apt-get clean

WORKDIR /src/matter
RUN git init
RUN git remote add origin https://github.com/project-chip/connectedhomeip.git
RUN git fetch --depth 1 origin 9a41c9c3d971797010ab9de4eb04804015674fb0
RUN git checkout FETCH_HEAD
RUN git config --global --add safe.directory /src/matter/third_party/pigweed/repo
SHELL ["/bin/bash", "-c"]
RUN scripts/checkout_submodules.py --shallow --platform linux
RUN source scripts/activate.sh \
&& deactivate
RUN source scripts/activate.sh \ 
&& scripts/build_python.sh -m platform -i separate

FROM python:3.8

RUN apt-get update \
&& apt-get install -y -qq git gcc g++ pkg-config libssl-dev libdbus-1-dev \
libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev \
ca-certificates curl gnupg lsb-release wget conntrack python-is-python3 avahi-daemon \
build-essential libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
&& apt-get clean

WORKDIR /src/

# TBD multi-stage build with slim base image
RUN git clone https://github.com/silveryfu/kopf.git && \
    cd kopf && git checkout digi && pip install -e .
RUN git clone https://github.com/silveryfu/zed.git && \
    mv zed/python/zed zed-cli && pip install -e ./zed-cli && rm -r zed/
COPY driver/requirements.txt ./driver/requirements.txt
RUN cd driver; pip install -r requirements.txt

COPY driver ./driver
RUN pip install -e ./driver

WORKDIR /src/matter
COPY --from=builder /src/matter/out/python_lib/controller/python/*.whl ./
RUN cd /src/matter && pip install *.whl

WORKDIR /src/

COPY --from=builder /src/matter/credentials/development/paa-root-certs ./paa-root-certs

COPY *.txt *.yml *.yaml ./
RUN pip install -r thirdparty.txt > /dev/null 2>&1 || true

COPY *.py ./
CMD /etc/init.d/dbus start && /etc/init.d/avahi-daemon start && python3 handler.py

