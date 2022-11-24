#!/bin/bash

install_deps() {
  sudo apt-get update > /dev/null
  sudo apt-get install -y -qq git gcc g++ pkg-config libssl-dev libdbus-1-dev \
  libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev \
  python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev \
  ca-certificates curl gnupg lsb-release wget conntrack python-is-python3 avahi-daemon > /dev/null
}

install_docker() {
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
	  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update > /dev/null
  sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null
  sudo service docker start
  sudo groupadd docker
  sudo usermod -aG docker $USER
}

install_go() {
  cd /tmp
  curl -LO https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bashrc
  export PATH=$PATH:/usr/local/go/bin
  echo 'export GOPATH=/home/vagrant/go' >> /home/vagrant/.bashrc
  export GOPATH=/home/vagrant/go
  mkdir -p $GOPATH
  source /home/vagrant/.bashrc
}

install_kubectl_cli() {
  sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo apt-get update > /dev/null
  sudo apt-get install -y kubectl > /dev/null
}

install_minikube() {
  cd /tmp
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  echo 'alias kubectl="minikube kubectl --"' >> /home/vagrant/.bashrc
  alias kubectl="minikube kubectl --"
  mkdir -p $GOPATH/src
  source /home/vagrant/.bashrc
}

install_matter() {
  cd /home/vagrant
  mkdir /home/vagrant/matter
  cd /home/vagrant/matter
  git init
  git remote add origin https://github.com/project-chip/connectedhomeip.git
  git fetch --depth 1 origin 9a41c9c3d971797010ab9de4eb04804015674fb0
  git checkout FETCH_HEAD
  git config --global --add safe.directory /home/vagrant/matter/third_party/pigweed/repo
  cd /home/vagrant/matter
  scripts/checkout_submodules.py --shallow --platform linux
  source scripts/activate.sh
  scripts/build_python.sh -m platform -i separate
  source ./out/python_env/bin/activate
}

install_kubectl_krew() {
  (
    set -x; cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
  )
  echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/vagrant/.bashrc
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  source /home/vagrant/.bashrc
}

install_kubectl_neat() {
  cd $GOPATH/src
  git clone https://github.com/silveryfu/kubectl-neat.git
  cd $GOPATH/src/kubectl-neat
  go install
}

install_kubectl_ctx() {
  kubectl krew install ctx
}

install_zed() {
  cd $GOPATH/src
  git clone https://github.com/silveryfu/zed.git
  cd $GOPATH/src/zed
  go install ./cmd/zed
  go install ./cmd/zq
}

install_helm3() {
  cd /tmp
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
}

install_digi() {
  mkdir -p $GOPATH/src/digi.dev
  cd $GOPATH/src/digi.dev
  git clone https://github.com/digi-project/digi.git
  ln -s $GOPATH/src/digi.dev/digi /home/vagrant/digi
  cd $GOPATH/src/digi.dev/digi
  echo 'export PATH=$PATH:/home/vagrant/go/bin' >> /home/vagrant/.bashrc
  export PATH=$PATH:/home/vagrant/go/bin
  source /home/vagrant/.bashrc
  git checkout digi-0.2.4
  make digi
  make install
}

install_digi_dep() {
  install_kubectl_krew
  install_kubectl_neat
  install_kubectl_ctx
  install_zed
  install_helm3
}

install_digi_extras() {
  cd /home/vagrant
  git clone https://github.com/digi-project/mocks.git
  git clone https://github.com/digi-project/examples.git
  git clone https://github.com/digi-project/demo.git
  git clone https://github.com/digi-project/recording.git
}

# config_digi() {
#   digi config --driver-repo 192.168.49.1:5000
# }

startup() {
  sg docker -c "minikube start && digi space start"
}

install_deps
install_go
install_docker
install_kubectl_cli
install_minikube
install_digi_dep
install_digi
install_digi_extras
install_matter
startup
