#!/bin/bash
set -e
# 1. Create cluster from kind config
kind create cluster --name todo-cluster --config cluster.yml
# 2. Get node names
WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[1].metadata.name}')
# 3. Label worker node for MySQL
kubectl label nodes $WORKER_NODE app=mysql --overwrite
# 4. Label worker node for todoapp
kubectl label nodes $WORKER_NODE app=todoapp --overwrite
# 5. Taint node for MySQL
kubectl taint nodes $WORKER_NODE app=mysql:NoSchedule
# 6. Apply all manifests
kubectl apply -f mysql-namespace.yaml
kubectl apply -f todoapp-namespace.yaml
kubectl apply -f mysql-secrets.yaml
kubectl apply -f app-secret.yaml
kubectl apply -f app-config.yaml
kubectl apply -f mysql-configmap.yaml
kubectl apply -f pvc-data.yaml
kubectl apply -f mysql-statefulset.yaml
kubectl apply -f mysql-service.yaml
kubectl apply -f todoapp-deployment.yaml
# 7. Wait for pods
kubectl wait --for=condition=ready pod -l app=mysql -n mysql --timeout=300s
kubectl wait --for=condition=ready pod -l app=todoapp -n todoapp --timeout=300s
echo "Deployment complete!"
