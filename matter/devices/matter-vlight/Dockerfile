FROM ubuntu:latest

RUN apt-get update && apt-get install -y -qq pkg-config libssl-dev libdbus-1-dev \
  libglib2.0-dev libavahi-client-dev \
  libgirepository1.0-dev libcairo2-dev libreadline-dev \
  ca-certificates gnupg lsb-release conntrack avahi-daemon \
&& apt-get clean

WORKDIR /src/

COPY matter-vlight matter-vlight

CMD ["./matter-vlight"]
