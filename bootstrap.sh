#!/bin/bash
set -e

# Deploy all Kubernetes resources from a single directory
kubectl apply -f infrastructure/

echo "Deployment completed successfully"

