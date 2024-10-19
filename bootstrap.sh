#!/bin/bash
# Create the namespace for MySQL
kubectl create namespace mysql

# Create the secrets for MySQL
kubectl apply -f mysql-secret.yml

# Deploy the StatefulSet and Headless Service for MySQL
kubectl apply -f mysql-statefulset.yml

# Create the namespace for todoapp
kubectl create namespace todoapp

# Create the ConfigMap and Secrets for todoapp
kubectl apply -f todoapp-configmap.yml
kubectl apply -f todoapp-secrets.yml

# Deploy the PVC and Deployment for todoapp
kubectl apply -f todoapp-pvc.yml
kubectl apply -f todoapp-deployment.yml

# Verify everything is running
kubectl get all --all-namespaces
