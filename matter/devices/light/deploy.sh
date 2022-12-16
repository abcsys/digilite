#!/bin/bash

MINIKUBE_IP=$(minikube ssh grep host.minikube.internal /etc/hosts | cut -f1 -s -z)

docker build -t ${MINIKUBE_IP}:5000/matter-light .
docker image tag ${MINIKUBE_IP}:5000/matter-light localhost:5000/matter-light
docker push localhost:5000/matter-light
kubectl delete --all -f light.yml
kubectl delete --all -f ../../util/external-mdns.yml
kubectl apply -f light.yml
kubectl apply -f ../../util/external-mdns.yml
