# INSTRUCTION.md — Validation Guide

This document explains how to validate that the scheduling rules (taints, tolerations, node affinity, and pod anti-affinity) are working correctly after deploying the cluster.

---

## Prerequisites

- [kind](https://kind.sigs.k8s.io/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- Docker running

---

## 1. Deploy Everything

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

---

## 2. Verify Node Labels and Taints

### Check node labels
```bash
kubectl get nodes --show-labels
```
You should see nodes with `app=mysql` and `app=todoapp` labels (as defined in `cluster.yml`).

### Check node taints
```bash
kubectl describe nodes | grep -A5 "Taints"
```
Nodes labeled `app=mysql` should have the taint `app=mysql:NoSchedule`.

---

## 3. Validate MySQL StatefulSet Scheduling

### Check that MySQL pods are running only on `app=mysql` nodes
```bash
kubectl get pods -n mysql -o wide
```
All MySQL pods should be on nodes labeled `app=mysql`.

### Verify Pod Anti-Affinity (no two MySQL pods on the same node)
```bash
kubectl get pods -n mysql -o wide
```
Each MySQL pod should be on a **different** node.

### Verify Toleration is applied (pods scheduled despite taint)
```bash
kubectl describe pod -n mysql mysql-0 | grep -A5 "Tolerations"
```
You should see `app=mysql:NoSchedule` in the tolerations.

---

## 4. Validate TodoApp Deployment Scheduling

### Check that TodoApp pods prefer `app=todoapp` nodes
```bash
kubectl get pods -n todoapp -o wide
```
Pods should be scheduled preferably on nodes labeled `app=todoapp`.

### Verify Pod Anti-Affinity (no two TodoApp pods on the same node)
```bash
kubectl get pods -n todoapp -o wide
```
Each TodoApp pod should be on a **different** node.

### Verify Node Affinity is configured
```bash
kubectl describe pod -n todoapp <pod-name> | grep -A15 "Node-Affinity"
```
You should see a `PreferredDuringSchedulingIgnoredDuringExecution` rule targeting `app=todoapp`.

---

## 5. Validate HPA

```bash
kubectl get hpa -n todoapp
```
The HPA should show min/max replicas and CPU/memory targets.

---

## 6. Validate Ingress

```bash
kubectl get ingress -n todoapp
```
The ingress should list the todoapp service with path routing configured.

---

## 7. Negative Test — Taint Enforcement

To confirm that non-tolerating pods are blocked from `app=mysql` nodes, try creating a plain pod without toleration on a tainted node and confirm it stays in `Pending` state:

```bash
kubectl run test-pod --image=nginx -n default
kubectl get pod test-pod -o wide
kubectl describe pod test-pod | grep -i "node(s) had taint"
```

Delete the test pod afterwards:
```bash
kubectl delete pod test-pod
```

---

## Summary Table

| Rule | Resource | Validation Command |
|---|---|---|
| Taint `app=mysql:NoSchedule` | Node | `kubectl describe nodes \| grep Taints` |
| Toleration for mysql taint | StatefulSet | `kubectl describe pod -n mysql mysql-0 \| grep Tolerations` |
| MySQL Node Affinity (required) | StatefulSet | `kubectl get pods -n mysql -o wide` |
| MySQL Pod Anti-Affinity | StatefulSet | `kubectl get pods -n mysql -o wide` (different nodes) |
| TodoApp Node Affinity (preferred) | Deployment | `kubectl describe pod -n todoapp <pod> \| grep Node-Affinity` |
| TodoApp Pod Anti-Affinity | Deployment | `kubectl get pods -n todoapp -o wide` (different nodes) |