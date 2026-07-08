#!/usr/bin/env bash

set -Eeuo pipefail

CLUSTER_NAME="kind"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${ROOT_DIR}"

for command in kind kubectl; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Error: ${command} is required but is not installed." >&2
    exit 1
  fi
done

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Using existing kind cluster '${CLUSTER_NAME}'."
else
  echo "Creating kind cluster '${CLUSTER_NAME}'..."
  kind create cluster --name "${CLUSTER_NAME}" --config cluster.yml
fi

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null
kubectl wait --for=condition=Ready nodes --all --timeout=180s

echo "Configuring node labels and taints..."
kubectl label node kind-worker kind-worker2 app=mysql --overwrite
kubectl label node kind-worker3 kind-worker4 kind-worker5 app=todoapp --overwrite
kubectl taint node kind-worker kind-worker2 app=mysql:NoSchedule --overwrite

echo "Installing ingress-nginx..."
kubectl apply -f \
  https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait \
  --namespace ingress-nginx \
  --for=condition=Available deployment/ingress-nginx-controller \
  --timeout=180s

echo "Deploying MySQL..."
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "Deploying Todo application..."
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "Waiting for workloads..."
kubectl rollout status statefulset/mysql --namespace mysql --timeout=300s
kubectl rollout status deployment/todoapp --namespace todoapp --timeout=300s

echo
echo "MySQL Pods:"
kubectl get pods --namespace mysql -o wide

echo
echo "Todo application Pods:"
kubectl get pods --namespace todoapp -o wide

echo
echo "Bootstrap completed."
