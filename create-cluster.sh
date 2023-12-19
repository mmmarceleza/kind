#!/bin/bash

# create the cluster
kind create cluster --image kindest/node:v1.26.6 --config ~/git/mmmarceleza/kind/config.yaml

# install metrics-server (https://github.com/kubernetes-sigs/metrics-server)
helm upgrade --install metrics-server metrics-server -n metrics-server --create-namespace \
--repo https://kubernetes-sigs.github.io/metrics-server/ \
--version 3.11.0 \
--set args={--kubelet-insecure-tls} \
--wait

