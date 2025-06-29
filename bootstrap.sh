#!/bin/bash
set -e

echo "⏳ Creating KIND cluster..."
kind create cluster --config cluster.yml

echo "🔖 Labeling and tainting nodes..."

# Get worker nodes
MYSQL_NODE=$(kubectl get nodes -o name | grep worker | sed -n 1p | cut -d'/' -f2)
TODOAPP_NODE_1=$(kubectl get nodes -o name | grep worker | sed -n 2p | cut -d'/' -f2)
TODOAPP_NODE_2=$(kubectl get nodes -o name | grep worker | sed -n 3p | cut -d'/' -f2)

# Label and taint mysql node
kubectl label node "$MYSQL_NODE" app=mysql --overwrite
kubectl taint node "$MYSQL_NODE" app=mysql:NoSchedule --overwrite

# Label todoapp nodes
kubectl label node "$TODOAPP_NODE_1" app=todoapp --overwrite
kubectl label node "$TODOAPP_NODE_2" app=todoapp --overwrite

echo "🚀 Deploying MySQL StatefulSet..."
kubectl apply -f statefulset.yml

echo "🚀 Deploying ToDoApp Deployment..."
kubectl apply -f deployment.yml

echo "⏳ Waiting for rollouts..."
kubectl rollout status statefulset/mysql
kubectl rollout status deployment/todoapp

echo "✅ Everything deployed successfully!"
