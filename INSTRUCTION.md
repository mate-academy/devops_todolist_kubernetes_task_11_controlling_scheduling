# Validation Instructions for Kubernetes ToDo App & MySQL Deployment

This document provides step-by-step instructions to validate the cluster configuration, node scheduling rules, taints, labels, and affinity constraints.

---

## 1. Cluster Deployment

Run the automated bootstrap script to spin up the Kind cluster, apply node taints, and deploy all required manifests:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 2. Validate Node Labels and Taints
Check Node Labels
Verify that the worker nodes are properly labeled (app=mysql and app=todoapp):

```Bash
kubectl get nodes --show-labels
```

Check Taints on MySQL Nodes
Verify that nodes labeled with app=mysql have the app=mysql:NoSchedule taint applied:

```Bash
kubectl describe nodes -l app=mysql | grep -i taints
```

## 3. Validate StatefulSet (MySQL) Placement
Check the scheduling status and node placement of the MySQL pods:

```Bash
kubectl get pods -n mysql -o wide
```

Verification Criteria:

Tolerations & Node Affinity: MySQL pods are scheduled exclusively on worker nodes labeled with `app=mysql`.

Pod Anti-Affinity: Each MySQL pod replica runs on a different node (not co-located on the same hostname).

## 4. Validate Deployment (ToDo App) Placement
Check the scheduling status and node placement of the ToDo App pods:

```Bash
kubectl get pods -n todoapp -o wide
```

Verification Criteria:

Preferred Node Affinity: ToDo App pods prefer placement on worker nodes labeled with app=todoapp.

Pod Anti-Affinity: ToDo App pods are scheduled across separate nodes to prevent single-node failure impact.

## 5. Verify Overall Resource Health
Ensure all pods, services, and volume claims are in the Running / Bound state:

```Bash
kubectl get all,pvc -n mysql
kubectl get all,pvc -n todoapp
```

