#!/bin/bash
set -e

echo "[bootstrap] 🚀 Creating Kubernetes cluster..."
kind create cluster --config infrastructure/cluster.yml

echo "[bootstrap] 🏷️ Labeling and tainting nodes..."
kubectl label nodes kind-worker app=mysql --overwrite
kubectl label nodes kind-worker2 app=todoapp --overwrite
kubectl taint nodes kind-worker app=mysql:NoSchedule --overwrite

echo "[bootstrap] 📦 Deploying MySQL StatefulSet..."
kubectl apply -f infrastructure/statefulset-mysql.yml

echo "[bootstrap] 📦 Deploying ToDo App..."
kubectl apply -f infrastructure/deployment-todoapp.yml

echo "[bootstrap] ✅ Deployment completed!"
