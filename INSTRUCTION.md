# Validation Instructions

## 1. Create and Configure the Cluster

```bash
kind create cluster --config cluster.yml

# Verify cluster creation
kubectl get nodes
```

## 2. Verify Node Labels and Taints

```bash
# Check node labels
kubectl get nodes --show-labels

# Verify that nodes have correct labels:

# Add taints to mysql nodes
kubectl taint nodes -l app=mysql app=mysql:NoSchedule

kubectl describe nodes | grep Taints
```

## 3. Deploy Resources

```bash
# Make bootstrap script executable
chmod +x bootstrap.sh

# Run bootstrap script
./bootstrap.sh
```

## 4. Validate MySQL StatefulSet

```bash
# Check if pods are running
kubectl get pods -n mysql

# Verify pod scheduling
kubectl describe pods -n mysql | grep "Node:"
```

## 5. Validate TodoApp Deployment

```bash
# Check if pods are running
kubectl get pods -n todoapp

# Verify pod scheduling
kubectl describe pods -n todoapp | grep "Node:"
```

## 6. Verify Application Functionality

```bash
# Get the NodePort service URL
kubectl get svc -n todoapp todoapp-nodeport

# Access the application using the NodePort
curl http://localhost:<NODE_PORT>/api/health
```

## Expected Results

1. MySQL StatefulSet:
   - Pods should be running on nodes with app=mysql label
   - Pods should be distributed across different nodes
   - Pods should be running despite the NoSchedule taint

2. TodoApp Deployment:
   - Pods should be running on nodes with app=todoapp label
   - Pods should be distributed across different nodes
   - Application should be accessible via NodePort

```bash
kubectl describe pods -n mysql
kubectl describe pods -n todoapp
kubectl describe nodes
``` 