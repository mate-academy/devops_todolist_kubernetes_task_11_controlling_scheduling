#!/bin/bash

echo "--- 1. Preparing Nodes (Labels & Taints) ---"
# Налаштовуємо ноди для MySQL (Воркери 1 та 2)
kubectl label nodes kind-worker kind-worker2 app=mysql --overwrite
kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule --overwrite

# Налаштовуємо ноди для Todoapp (Воркери 3, 4 та 5)
kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp --overwrite

echo "--- 2. Deploying MySQL Infrastructure ---"
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "Waiting for MySQL to start..."
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=60s

echo "--- 3. Deploying Application Infrastructure ---"
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

echo "--- 4. Installing Ingress Controller ---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Waiting for Ingress Controller to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=controller -n ingress-nginx --timeout=120s

echo "--- 5. Deploying Ingress Rules ---"
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "--- Deployment Complete! ---"
kubectl get pods -A -o wide