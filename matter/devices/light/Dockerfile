FROM ubuntu:latest AS builder
WORKDIR /src/
RUN apt-get update \
&& apt-get install -y -qq git gcc g++ pkg-config libssl-dev libdbus-1-dev \
libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev \
ca-certificates curl gnupg lsb-release wget conntrack python-is-python3 avahi-daemon \
build-essential libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev \
&& apt-get clean

SHELL ["/bin/bash", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
RUN export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" \
&& [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
&& nvm install 16 \
&& nvm use 16 \
&& which node

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
&& export PATH=/root/.nvm/versions/node/v16.18.1/bin:$PATH \
&& cd /src/matter/third_party/zap/repo \
&& npm ci \
&& cd /src/matter/examples/chef \
&& ./chef.py -zb -t linux -d rootnode_onofflight_bbs1b7IaOV --enable_ipv4

FROM ubuntu:latest

RUN apt-get update \
&& apt-get install -y -qq pkg-config libssl-dev libdbus-1-dev \
  libglib2.0-dev libavahi-client-dev \
  libgirepository1.0-dev libcairo2-dev libreadline-dev \
  ca-certificates gnupg lsb-release conntrack avahi-daemon \
&& apt-get clean

WORKDIR /src/

COPY --from=builder /src/matter/examples/chef/linux/out/rootnode_onofflight_bbs1b7IaOV ./light

CMD ["./light"]
