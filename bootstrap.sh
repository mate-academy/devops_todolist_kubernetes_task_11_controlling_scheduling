#!/bin/bash

echo "Creating cluster..."
kind create cluster --config cluster.yml
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "Labeling nodes..."
kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp
kubectl label nodes kind-worker kind-worker2 kind-worker5 app=mysql

echo "Tainting nodes..."
kubectl get nodes -l app=mysql -o name | xargs -r -n1 kubectl taint nodes {} app=mysql:NoSchedule --overwrite

echo "Launching mysql databases..."
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "Launching python apps..."
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

echo "Set up ingress..."
# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=120s
kubectl apply -f .infrastructure/ingress/ingress.yml
