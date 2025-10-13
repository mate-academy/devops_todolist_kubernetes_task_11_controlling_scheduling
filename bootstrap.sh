#!/bin/bash

echo "Creating cluster..."
kind create cluster --config cluster.yml
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "Labeling nodes..."
workers=( $(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}\n{end}' | grep kind-worker) )
# Ensure at least one worker
if [ ${#workers[@]} -lt 1 ]; then echo "no worker nodes found"; exit 1; fi
# label first N as mysql
for n in "${workers[@]:0:2}"; do kubectl label node "$n" app=mysql --overwrite; done
# label remaining nodes as todoapp
for n in "${workers[@]:2}"; do kubectl label node "$n" app=todoapp --overwrite; done

echo "Tainting nodes..."
kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}' | xargs -r -n1 -I {} kubectl taint nodes {} app=mysql:NoSchedule --overwrite
echo "Launching mysql databases..."
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml
kubectl -n mysql rollout status statefulset/mysql --timeout=120s


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
kubectl -n todoapp rollout status deployment/todoapp --timeout=120s


echo "Set up ingress..."
# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=120s
kubectl apply -f .infrastructure/ingress/ingress.yml
