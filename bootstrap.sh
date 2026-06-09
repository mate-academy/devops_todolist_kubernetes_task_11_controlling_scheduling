#!/bin/bash
set -euo pipefail

if [ ! -f cluster.yml ]; then
  echo "cluster.yml is required but was not found in the repository root"
  exit 1
fi

kind create cluster --config cluster.yml --name todoapp

kubectl wait --for=condition=Ready nodes --all --timeout=180s

kubectl label node todoapp-worker app=mysql --overwrite
kubectl label node todoapp-worker2 app=mysql --overwrite
kubectl label node todoapp-worker3 app=todoapp --overwrite
kubectl label node todoapp-worker4 app=todoapp --overwrite
kubectl label node todoapp-worker5 app=todoapp --overwrite

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f .infrastructure/ingress/ingress.yml
