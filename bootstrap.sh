#!/bin/bash
set -euo pipefail

# 1. Create the Kind cluster
echo "Creating Kind cluster from cluster.yml..."
kind create cluster --config cluster.yml

# 2. Wait for nodes to reach 'Ready' status
echo "Waiting for nodes to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 3. Taint nodes labeled with app=mysql
echo "Tainting MySQL nodes with app=mysql:NoSchedule..."
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# 4. Deploy MySQL infrastructure
echo "Deploying MySQL infrastructure..."
kubectl apply -f ./.infrastructure/mysql/ns.yml
kubectl apply -f ./.infrastructure/mysql/secret.yml
kubectl apply -f ./.infrastructure/mysql/configMap.yml
kubectl apply -f ./.infrastructure/mysql/service.yml
kubectl apply -f ./.infrastructure/mysql/statefulSet.yml

# 5. Deploy Todoapp infrastructure
echo "Deploying Todoapp infrastructure..."
kubectl apply -f ./.infrastructure/app/ns.yml
kubectl apply -f ./.infrastructure/app/pv.yml
kubectl apply -f ./.infrastructure/app/pvc.yml
kubectl apply -f ./.infrastructure/app/secret.yml
kubectl apply -f ./.infrastructure/app/configMap.yml
kubectl apply -f ./.infrastructure/app/deployment.yml
kubectl apply -f ./.infrastructure/app/clusterIp.yml

echo "Infrastructure setup is complete!"