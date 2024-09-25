#!/bin/bash

# create the cluster
kind create cluster --image kindest/node:v1.30.2 --config ~/git/mmmarceleza/github/kind/config.yaml

# adding taint to infra node
kubectl taint node kind-worker dedicated=infra:NoSchedule 

# adding role labels
kubectl label node kind-worker node-role.kubernetes.io/infra=""
kubectl label node kind-worker2 node-role.kubernetes.io/worker=""
kubectl label node kind-worker3 node-role.kubernetes.io/worker=""

# install metrics-server (https://github.com/kubernetes-sigs/metrics-server)
helm upgrade --install metrics-server metrics-server -n metrics-server --create-namespace \
--repo "https://kubernetes-sigs.github.io/metrics-server" \
--version "3.12.1" \
--set "args={--kubelet-insecure-tls}"

# install Ingress NGINX Controller (https://github.com/kubernetes/ingress-nginx)
helm upgrade --install ingress-nginx ingress-nginx -n ingress-nginx --create-namespace \
--repo "https://kubernetes.github.io/ingress-nginx" \
--version "4.11.1" \
--set "controller.hostPort.enabled=true" \
--set "controller.nodeSelector.role=infra" \
--set "controller.tolerations[0].key=dedicated" \
--set "controller.tolerations[0].value=infra" \
--set "controller.tolerations[0].effect=NoSchedule" \
--set "controller.service.enabled=false" \
--set "controller.service.external.enabled=true" \
--wait

# install kube-prometheus-stack
helm upgrade --install monitoring kube-prometheus-stack -n monitoring --create-namespace \
--repo "https://prometheus-community.github.io/helm-charts" \
--version "61.7.0" \
--set "fullnameOverride=monitoring" \
--set "alertmanager.alertmanagerSpec.tolerations[0].key=dedicated" \
--set "alertmanager.alertmanagerSpec.tolerations[0].value=infra" \
--set "alertmanager.alertmanagerSpec.tolerations[0].effect=NoSchedule" \
--set "alertmanager.alertmanagerSpec.nodeSelector.role=infra" \
--set "alertmanager.ingress.enabled=true" \
--set "alertmanager.ingress.ingressClassName=nginx" \
--set "alertmanager.ingress.hosts={alertmanager.127-0-0-1.nip.io}" \
--set "alertmanager.ingress.paths={/}" \
--set "grafana.ingress.enabled=true" \
--set "grafana.ingress.ingressClassName=nginx" \
--set "grafana.ingress.hosts={grafana.127-0-0-1.nip.io}" \
--set "grafana.ingress.paths={/}" \
--set "prometheus.ingress.enabled=true" \
--set "prometheus.ingress.ingressClassName=nginx" \
--set "prometheus.ingress.hosts={prometheus.127-0-0-1.nip.io}" \
--set "prometheus.ingress.paths={/}"
