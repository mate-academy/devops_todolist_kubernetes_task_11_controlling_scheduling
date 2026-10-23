#!/bin/bash
set -e

kind create cluster --name todo-lab --config cluster.yml

kubectl config use-context kind-todo-lab
kubectl get nodes -L app

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

# MySQL
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

# Application
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/deployment.yml
kubectl apply -f .infrastructure/app/hpa.yml

