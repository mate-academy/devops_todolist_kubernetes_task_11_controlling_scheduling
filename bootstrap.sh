#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-todolist-scheduling}"
KIND_CONFIG="${KIND_CONFIG:-cluster.yml}"
CLEAN_EXISTING_KIND_CLUSTERS="${CLEAN_EXISTING_KIND_CLUSTERS:-true}"

if [[ "${CLEAN_EXISTING_KIND_CLUSTERS}" == "true" ]]; then
  while IFS= read -r existing_cluster; do
    [[ -z "${existing_cluster}" ]] && continue
    if [[ "${existing_cluster}" != "${CLUSTER_NAME}" ]]; then
      echo "===> Removing existing kind cluster: ${existing_cluster}"
      kind delete cluster --name "${existing_cluster}"
    fi
  done < <(kind get clusters 2>/dev/null || true)
fi

kind delete cluster --name "${CLUSTER_NAME}" >/dev/null 2>&1 || true
kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"

echo "===> Waiting for nodes to become Ready"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "===> Nodes and labels"
kubectl get nodes --show-labels

echo "===> Tainting mysql nodes"
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "===> Nodes, labels, taints"
kubectl get nodes -L app -o custom-columns=NAME:.metadata.name,APP:.metadata.labels.app,TAINTS:.spec.taints

echo "===> Deploying mysql resources"
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "===> Deploying todoapp resources"
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/hpa.yml

echo "===> Installing ingress-nginx for kind"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
if ! kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s; then
  echo "WARNING: ingress-nginx controller is not Ready yet. Continuing deployment."
fi
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "===> Cluster workloads"
kubectl get pods -A -o wide
