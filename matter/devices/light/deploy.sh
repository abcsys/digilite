#!/bin/bash

docker build -t 192.168.49.1:5000/matter-light .
docker image tag 192.168.49.1:5000/matter-light localhost:5000/matter-light
docker push localhost:5000/matter-light
kubectl delete -f light.yml
kubectl apply -f light.yml
