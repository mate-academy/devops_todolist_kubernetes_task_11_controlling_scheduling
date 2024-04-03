# Deployment Guide for Django ToDo App on Kubernetes
This guide walks you through deploying a Django-based ToDo list application on a Kubernetes cluster created with kind.

## Prerequisites
- Docker
- kind (Kubernetes in Docker)
- kubectl (Kubernetes CLI)

## Setup Instructions

1. Create a Kubernetes Cluster
```bash
kind create cluster --config=cluster.yml
```

2. Run the Bootstrap Script
```bash
./bootstrap.sh
```

3. Verify the Deployment
```bash
kubectl get pods
```

4. Access the Application
```bash
kubectl port-forward service/todoapp 8000:8000
```

## Checking Resource Scheduling and Allocation

1. Verify Pod Scheduling
```bash
kubectl get pods -o wide
```

2. Check Pod Details
```bash
kubectl describe pod <pod-name>
```

### Node Affinity and Taints Verification

1. Check Node Affinity
```bash
kubectl get nodes --show-labels
```

2. Verify Taints and Tolerations
```bash
kubectl describe node <node-name>
```

### Pod Anti-Affinity Verification

1. Check Pod Distribution
```bash
kubectl get pods -o wide
```
Verify that the pods subject to anti-affinity rules are not on the same node.
Replace <pod-name>, <node-name> with the relevant values for your setup. This README structure provides a comprehensive guide for users to deploy and access the Todo App using the provided bootstrap.sh script.
