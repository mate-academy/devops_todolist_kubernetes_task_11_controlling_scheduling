#!/bin/bash
set -e

# --- Scheduling setup -------------------------------------------------
# Nodes are labeled app=mysql / app=todoapp at cluster-creation time via
# cluster.yml's kubeadm JoinConfiguration node-labels. Here we taint the
# node(s) labeled app=mysql so that only pods tolerating that taint
# (the mysql StatefulSet) can be scheduled there.
echo "Inspecting node labels and taints..."
kubectl get nodes --show-labels
kubectl describe nodes | grep -A3 "Taints:"

echo "Tainting nodes labeled app=mysql with app=mysql:NoSchedule..."
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# --- MySQL -------------------------------------------------------------
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# --- ToDo app ------------------------------------------------------------
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

# --- Ingress -------------------------------------------------------------
# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for the ingress-nginx admission webhook/controller pod to be ready
# before applying any Ingress resources, otherwise the apply below can
# fail or the rule can silently not take effect.
echo "Waiting for ingress-nginx controller to become ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

kubectl apply -f .infrastructure/ingress/ingress.yml
