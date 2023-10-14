#!/bin/bash

# create the cluster
kind create cluster --image kindest/node:v1.26.6

# install metrics-server (https://github.com/kubernetes-sigs/metrics-server)
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server -n metrics-server --create-namespace \
--version 3.10.0 \
--set args={--kubelet-insecure-tls} \
--wait