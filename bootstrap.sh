#!/bin/bash
set -e

echo "==> Creating cluster..."
kind create cluster --config cluster.yml

echo "==> Tainting mysql nodes..."
for node in $(kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}'); do
  kubectl taint nodes "$node" app=mysql:NoSchedule --overwrite
done

echo "==> Deploying MySQL namespace and resources..."
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "==> Waiting for MySQL pods to be ready..."
kubectl rollout status statefulset/mysql -n mysql --timeout=120s

echo "==> Deploying TodoApp namespace and resources..."
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "==> Waiting for TodoApp deployment to be ready..."
kubectl rollout status deployment/todoapp -n todoapp --timeout=120s

echo "==> All resources deployed successfully!"
kubectl get pods -n mysql
kubectl get pods -n todoapp