# Vagrant Testing Environment

## Pre-Requisites:
- Vagrant
- VirtualBox

## Requirements:
- 2x CPUs
- 4 GiBi RAM
- 65 GiBi of Storage

## Installation

`vagrant up`

## VM Libraries
- [Matter@9a41c9c](https://github.com/project-chip/connectedhomeip/commit/9a41c9c3d971797010ab9de4eb04804015674fb0)
- [Digi@0.2.7](https://github.com/digi-project/digi/commit/623d6f0e7e32681ae6e9a9e7ec5db21274c9560a)
- [Digi Mocks](https://github.com/digi-project/mocks)
- [Digi Examples](https://github.com/digi-project/examples)
- [Digi Demo](https://github.com/digi-project/demo)
- [Digi Recording](https://github.com/digi-project/recording)

## Post-Installation Steps:

```bash
# Outside VM
vagrant ssh
# In the VM:
sudo mkdir -p /etc/docker
sudo printf "{\"insecure-registries\": [\"192.168.49.1:5000\"]}" > /etc/docker/daemon.json
sudo systemctl restart docker
docker run -d -p 5000:5000 --name registry registry:2
minikube start --insecure-registry="192.168.49.1:5000"
digi space start
```