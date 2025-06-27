# INSTRUCTION.md

## ✅ Overview
This Kubernetes cluster includes two components:
- `mysql` as a `StatefulSet`
- `todoapp` as a `Deployment`

Each component is configured with the appropriate Affinity and Toleration rules.

---

## ⚙️ How to Validate the Configuration

### 1. Check node labels and taints

```bash
kubectl get nodes --show-labels
kubectl describe nodes | grep Taint
```

Expected:
- One node has the label `app=mysql` and the taint `app=mysql:NoSchedule`
- Another node has the label `app=todoapp` and no taint

---

### 2. Ensure `mysql` is scheduled on the tainted node

```bash
kubectl get pods -n mysql -o wide
```

Check that the pods are running on the node with the `app=mysql` label.

---

### 3. Verify Pod Anti-Affinity for `mysql`

```bash
kubectl get pods -n mysql -o wide
```

Ensure that the pods are **running on different nodes** (check the `NODE` column).

---

### 4. Ensure `todoapp` is scheduled on the `app=todoapp` node

```bash
kubectl get pods -n todoapp -o wide
```

Pods should be running on the node labeled `app=todoapp`.

---

### 5. Verify Pod Anti-Affinity for `todoapp`

```bash
kubectl get pods -n todoapp -o wide
```

Ensure that replicas are **not scheduled on the same node** (if there are multiple replicas).

---

## 📌 Useful Commands

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl get statefulset,pod -n mysql
kubectl get deployment,pod -n todoapp
```

---

## 📝 Note

To restart the cluster:

```bash
kind delete cluster
kind create cluster --config cluster.yml
./bootstrap.sh
```