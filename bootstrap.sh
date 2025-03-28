#!/bin/bash

echo "🚀 Створення Kubernetes кластера у Kind..."
kind create cluster --config=cluster.yml

echo "⏳ Очікуємо, поки всі ноди стануть готовими..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "🏷 Додавання taint для MySQL-нод..."
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "📦 Деплой MySQL..."
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

echo "📝 Деплой TodoApp..."
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

echo "🌍 Встановлення Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# kubectl apply -f .infrastructure/ingress/ingress.yml

echo "✅ Кластер готовий!"
kubectl get nodes -o wide
kubectl get pods -A -o wide
