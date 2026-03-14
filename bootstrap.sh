#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

CLUSTER_NAME="${CLUSTER_NAME:-todoapp-scheduling}"

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config cluster.yml
fi

echo "Inspecting node labels"
kubectl get nodes --show-labels

echo "Inspecting current node taints"
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

echo "Applying mysql taint to nodes labeled app=mysql"
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "Node taints after update"
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/hpa.yml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f .infrastructure/ingress/ingress.yml
