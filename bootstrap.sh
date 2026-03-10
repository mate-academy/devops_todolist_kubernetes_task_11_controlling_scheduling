#!/bin/bash
set -e

echo "--- 1. Preparing Nodes (Labels & Taints) ---"
kubectl label nodes todoapp-cluster-worker app=todoapp --overwrite
kubectl label nodes todoapp-cluster-worker2 app=mysql --overwrite
kubectl label nodes todoapp-cluster-worker3 app=mysql --overwrite

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "--- 2. Inspecting Nodes for Taints and Labels ---"
kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels.app,TAINTS:.spec.taints

echo "--- 3. Deploying MySQL (StatefulSet) ---"
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "--- 4. Deploying ToDo App (Deployment) ---"
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

echo "--- 5. Installing NGINX Ingress Controller ---"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "--- Waiting for Ingress Controller to be ready ---"
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

echo "--- 6. Applying Ingress Resources ---"
kubectl apply -f .infrastructure/ingress/ingress.yml

echo "--- Deployment Complete! ---"
kubectl get pods -A -o wide