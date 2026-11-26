#!/bin/bash

# Create the kind cluster (1 control-plane, 2 mysql workers, 3 todoapp workers, 1 neutral worker)
kind create cluster --config cluster.yml

# Wait until all nodes are Ready
kubectl wait --for=condition=Ready nodes --all --timeout=180s

# Taint the nodes labeled app=mysql
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
