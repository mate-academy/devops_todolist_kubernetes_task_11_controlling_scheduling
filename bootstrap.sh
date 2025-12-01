#!/bin/bash
set -e

CLUSTER_NAME="todolist"

# 1. Пересоздаём кластер
kind delete cluster --name "${CLUSTER_NAME}" >/dev/null 2>&1 || true
kind create cluster --name "${CLUSTER_NAME}" --config cluster.yml

# 2. Taint нод с app=mysql
MYSQL_NODES=$(kubectl get nodes -l app=mysql -o name | sed 's|node/||g')

for node in ${MYSQL_NODES}; do
  kubectl taint nodes "$node" app=mysql:NoSchedule --overwrite
done

# 3. Деплой MySQL
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# 4. Деплой приложения
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

# 5. (опционально) Ingress Controller
# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml
