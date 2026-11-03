# INSTRUCTION.md

# Kubernetes Scheduling: Taints, Tolerations and Affinity

## Prerequisites

Before starting, make sure the following tools are installed and running:

- Docker Desktop
- kubectl
- kind
- Git Bash

## 1. Create Kubernetes Cluster

From the project root directory, create a Kind cluster using the configuration file:

```bash
kind create cluster --config cluster.yml
```

Verify that all nodes are Ready:

```bash
kubectl get nodes
```

## 2. Inspect Nodes

Check node labels:

```bash
kubectl get nodes --show-labels
```

Check node taints:

```bash
kubectl describe nodes
```

## 3. Configure Node Labels and Taints

Assign labels to worker nodes:

```bash
kubectl label node kind-worker app=mysql --overwrite
kubectl label node kind-worker2 app=todoapp --overwrite
```

Apply the MySQL taint:

```bash
kubectl taint nodes kind-worker app=mysql:NoSchedule --overwrite
```

Verify the configuration:

```bash
kubectl get nodes --show-labels
kubectl describe nodes
```

## 4. Deploy Application Resources

Run the bootstrap script from the project root:

```bash
bash ./bootstrap.sh
```

The script deploys MySQL and ToDoApp resources and installs the NGINX Ingress Controller.

## 5. Verify StatefulSet Scheduling Rules

Inspect the MySQL StatefulSet:

```bash
kubectl get statefulset -n mysql
kubectl describe statefulset mysql -n mysql
```

Verify that the StatefulSet includes:

- Toleration for `app=mysql:NoSchedule`.
- Required Node Affinity for nodes labeled `app=mysql`.
- Required Pod Anti-Affinity using `kubernetes.io/hostname`.

Check MySQL pods and their assigned nodes:

```bash
kubectl get pods -n mysql -o wide
```

MySQL pods should be scheduled only on nodes labeled `app=mysql`, with no two MySQL pods on the same node.

## 6. Verify Deployment Scheduling Rules

Inspect the ToDoApp Deployment:

```bash
kubectl get deployment -n todoapp
kubectl describe deployment todoapp -n todoapp
```

Verify that the Deployment includes:

- Preferred Node Affinity for nodes labeled `app=todoapp`.
- Required Pod Anti-Affinity using `kubernetes.io/hostname`.

Check ToDoApp pods and their assigned nodes:

```bash
kubectl get pods -n todoapp -o wide
```

ToDoApp replicas should be distributed across different nodes whenever possible.

## 7. Verify Cluster Resources

Check all pods:

```bash
kubectl get pods -A
```

Check services:

```bash
kubectl get services -A
```

Check StatefulSets and Deployments:

```bash
kubectl get statefulsets,deployments -A
```

Check scheduling events if any pod remains Pending:

```bash
kubectl get events -A --sort-by=.lastTimestamp
```

## 8. Expected Result

- The Kind cluster contains one control-plane node and two worker nodes.
- `kind-worker` has the label `app=mysql` and taint `app=mysql:NoSchedule`.
- `kind-worker2` has the label `app=todoapp`.
- MySQL pods tolerate the MySQL taint and use the required Node Affinity and Pod Anti-Affinity rules.
- ToDoApp pods use preferred Node Affinity and required Pod Anti-Affinity rules.
- All required resources are deployed successfully.
- 