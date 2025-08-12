# Validation Instructions

This document provides step-by-step instructions to validate the Kubernetes configurations for the ToDo application deployment.

## Prerequisites

- `kind` cluster is running
- `kubectl` is configured to connect to the cluster
- All resources have been deployed using `bootstrap.sh`

## 1. Verify Cluster Setup

Check that the cluster is running and nodes are ready:

```bash
kubectl get nodes
```

Expected output: All nodes should be in `Ready` status.

## 2. Validate Node Labels and Taints

### Check Node Labels

Verify that nodes have the required labels:

```bash
kubectl get nodes --show-labels
```

Expected: You should see nodes labeled with `app=mysql` and `app=todoapp`.

### Check Node Taints

Verify that MySQL nodes are properly tainted:

```bash
kubectl describe nodes -l app=mysql
```

Expected: In the output, look for the "Taints" section showing `app=mysql:NoSchedule`.

## 3. Validate MySQL StatefulSet

### Check StatefulSet Status

```bash
kubectl get statefulset -n mysql
```

Expected: StatefulSet should show `2/2` ready replicas.

### Check Pod Scheduling

```bash
kubectl get pods -n mysql -o wide
```

Expected: 
- Both MySQL pods should be running
- They should be scheduled on different nodes (due to anti-affinity)
- They should only be on nodes labeled with `app=mysql`

### Verify Tolerations and Affinity

```bash
kubectl describe pod -n mysql -l app=mysql
```

Expected in the output:
- **Tolerations**: `app=mysql:NoSchedule`
- **Node-Selectors**: Should show affinity rules for `app=mysql` nodes
- **Anti-Affinity**: Should prevent scheduling on same node

## 4. Validate TodoApp Deployment

### Check Deployment Status

```bash
kubectl get deployment -n todoapp
```

Expected: Deployment should show ready replicas matching desired count.

### Check Pod Scheduling

```bash
kubectl get pods -n todoapp -o wide
```

Expected:
- All TodoApp pods should be running
- They should be scheduled on different nodes (due to anti-affinity)
- They should preferably be on nodes labeled with `app=todoapp`

### Verify Affinity Rules

```bash
kubectl describe pod -n todoapp -l app=todoapp
```

Expected in the output:
- **Node-Affinity**: Should show preferred scheduling for `app=todoapp` nodes
- **Anti-Affinity**: Should prevent scheduling on same node

## 5. Test Pod Anti-Affinity

### Scale MySQL StatefulSet

```bash
kubectl scale statefulset mysql -n mysql --replicas=3
```

Wait for the scaling operation and check:

```bash
kubectl get pods -n mysql -o wide
```

Expected: If you have only 2 nodes with `app=mysql` label, the third pod should remain in `Pending` state due to anti-affinity rules.

Scale back to 2:

```bash
kubectl scale statefulset mysql -n mysql --replicas=2
```

### Scale TodoApp Deployment

```bash
kubectl scale deployment todoapp -n todoapp --replicas=4
```

Check pod distribution:

```bash
kubectl get pods -n todoapp -o wide
```

Expected: Pods should be distributed across different nodes. If there are more replicas than available nodes, some pods may remain in `Pending` state due to anti-affinity.

## 6. Test Node Affinity

### Create a Test Pod Without Tolerations

Create a test pod to verify taint enforcement:

```bash
kubectl run test-pod --image=nginx --restart=Never -n mysql
```

Check the pod status:

```bash
kubectl get pod test-pod -n mysql
kubectl describe pod test-pod -n mysql
```

Expected: Pod should be in `Pending` state with events showing it cannot be scheduled due to taints.

Clean up:

```bash
kubectl delete pod test-pod -n mysql
```
