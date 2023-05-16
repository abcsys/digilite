FROM ubuntu AS builder

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
RUN git fetch --depth 1 origin ef05822452bd698eed59723e0b22aff8da217163
RUN git checkout FETCH_HEAD
RUN git config --global --add safe.directory /src/matter/third_party/pigweed/repo
SHELL ["/bin/bash", "-c"]
RUN scripts/checkout_submodules.py --shallow --platform linux
RUN source scripts/activate.sh \
&& deactivate
RUN source scripts/activate.sh \
&& scripts/examples/gn_build_example.sh examples/chip-tool out/

FROM ubuntu
WORKDIR /src/
RUN apt-get update \
&& apt-get install -y -qq git gcc g++ pkg-config libssl-dev libdbus-1-dev \
libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev \
ca-certificates curl gnupg lsb-release wget conntrack python-is-python3 avahi-daemon \
build-essential libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
&& apt-get clean

WORKDIR /src/matter
COPY --from=builder /src/matter/out/chip-tool ./
COPY ./entrypoint.sh ./
CMD ["./entrypoint.sh"]