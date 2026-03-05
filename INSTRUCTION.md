# Instruction: Kubernetes Taints, Affinity & Anti-Affinity Validation

## Prerequisites

- `kind` installed
- `kubectl` installed
- Repository forked and cloned locally

---

## Step 1: Spin Up the Cluster

```bash
kind create cluster --config cluster.yml
```

Verify the cluster is running:

```bash
kubectl get nodes
```

Expected output: all nodes in `Ready` status.

---

## Step 2: Inspect Node Labels and Taints

Check labels on all nodes:

```bash
kubectl get nodes --show-labels
```

Check taints on all nodes:

```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```

Expected: nodes labeled `app=mysql` and `app=todoapp` are visible.

---

## Step 3: Taint Nodes with `app=mysql` Label

Apply `NoSchedule` taint to all nodes labeled `app=mysql`:

```bash
kubectl taint nodes <nodes> app=mysql:NoSchedule
```

Verify the taint was applied:

```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```

---

## Step 4: Deploy All Resources

Run the bootstrap script:

```bash
bash bootstrap.sh
```

This script deploys the StatefulSet and Deployment with all required configurations.

---

## Step 5: Validate StatefulSet (MySQL)

### Check that MySQL pods are running

```bash
kubectl get pods -o wide -n mysql
```
### Make sure that:
- all MySQL pods have Running status
- each MySQL pod is on a different node (check NODE column)
- the node has the app=mysql label

---

## Step 6: Validate Deployment (TodoApp)

### Check that TodoApp pods are running

```bash
kubectl get pods -o wide -n todoapp
```

### Make sure that:
- all TodoApp pods have Running status
- each TodoApp pod is on a different node (check NODE column)
- the node has the app=todoapp label


---

## Step 7: Full Validation Summary

Run all checks at once:

```bash
# All pods status and node placement
kubectl get pods -o wide -A

# Node labels
kubectl get nodes --show-labels

# Node taints
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```
