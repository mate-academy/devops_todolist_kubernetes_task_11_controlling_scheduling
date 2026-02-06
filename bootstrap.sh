#!/bin/bash

echo "Starting deployment..."

# 1. Ingress Controller
echo "Installing Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# 2. --- NODE LABELING AND TAINTING ---
echo "Configuring Node Labels and Taints..."

NODES=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}' | tr ' ' '\n' | grep worker)
NODE_ARRAY=($NODES)

kubectl label node ${NODE_ARRAY[0]} app=mysql --overwrite
kubectl label node ${NODE_ARRAY[1]} app=mysql --overwrite
kubectl taint nodes ${NODE_ARRAY[0]} app=mysql:NoSchedule --overwrite
kubectl taint nodes ${NODE_ARRAY[1]} app=mysql:NoSchedule --overwrite

kubectl label node ${NODE_ARRAY[2]} app=todoapp --overwrite

echo "Nodes configured:"
kubectl get nodes --show-labels

# 3. Base Infrastructure
kubectl apply -f .infrastructure/namespace.yml
kubectl apply -f .infrastructure/mysql-namespace.yml

# 4. MySQL Stack
kubectl apply -f .infrastructure/mysql-secret.yml
kubectl apply -f .infrastructure/mysql-configmap.yml
kubectl apply -f .infrastructure/mysql-service.yml
kubectl apply -f .infrastructure/statefulSet.yml

kubectl create secret generic mysql-app-credentials \
  --from-literal=NAME=tododb \
  --from-literal=USER=mate_user \
  --from-literal=PASSWORD=mate_password_secret \
  --from-literal=HOST=mysql-0.mysql-service.mysql.svc.cluster.local \
  -n mateapp --dry-run=client -o yaml | kubectl apply -f -

# 5. App Stack
kubectl apply -f .infrastructure/pv.yml
kubectl apply -f .infrastructure/pvc.yml
kubectl apply -f .infrastructure/configMap.yml
kubectl apply -f .infrastructure/secret.yml
# Застосовуємо оновлений Deployment
kubectl apply -f .infrastructure/deployment.yml
kubectl apply -f .infrastructure/service.yml
kubectl apply -f .infrastructure/ingress/ingress.yml

# 6. Background jobs
kubectl apply -f .infrastructure/hpa.yml
kubectl apply -f .infrastructure/daemonset.yml
kubectl apply -f .infrastructure/cronjob.yml

echo "Deployment finished!"