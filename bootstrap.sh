#!/bin/bash
set -euo pipefail

# 1. Create the kind cluster (cluster.yml must be in the repo root)
kind create cluster --config cluster.yml

# 2. Taint nodes labeled app=mysql with NoSchedule
MYSQL_NODES=$(kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}')
for NODE in $MYSQL_NODES; do
  kubectl taint nodes "$NODE" app=mysql:NoSchedule
done

# 3. Apply all manifests in correct order
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/StatefulSet.yml

kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/pod.yml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f .infrastructure/ingress/ingress.yml