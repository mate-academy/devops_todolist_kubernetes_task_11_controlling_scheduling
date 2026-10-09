#!/bin/bash

echo "Spinning up Kind cluster from cluster.yml..."
kind create cluster --config cluster.yml

echo "Applying Taints to mysql nodes..."
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

echo "Creating Namespaces..."
kubectl apply -f .infrastructure/mysql-namespace.yml 2>/dev/null || kubectl create namespace mysql
kubectl apply -f .infrastructure/namespace.yml 2>/dev/null || kubectl create namespace mateapp

echo "Deploying MySQL Workloads..."
kubectl apply -f .infrastructure/mysql-secret.yml
kubectl apply -f .infrastructure/mysql-init-config.yml
kubectl apply -f .infrastructure/statefulSet.yml

echo "Deploying Application Workloads..."
kubectl apply -f .infrastructure/configMap.yml
kubectl apply -f .infrastructure/secret.yml
kubectl apply -f .infrastructure/app-db-secret.yml
kubectl apply -f .infrastructure/deployment.yml

echo "All cluster resources applied successfully!"
