# INSTRUCTION.md

## ✅ Validation Instructions for Task 11: Controlling Scheduling

This guide explains how to verify that the `todoapp` and `mysql` components are scheduled according to the affinity, anti-affinity, taints, and tolerations requirements.

---

### 1. Check Node Labels and Taints

Make sure the required nodes are labeled and tainted correctly.

```sh
kubectl get nodes --show-labels
kubectl describe node kind-worker2 | grep Taints
```

Expected:

* `kind-worker2` has label: `app=mysql`
* `kind-worker2` has taint: `app=mysql:NoSchedule`

---

### 2. Verify MySQL is scheduled only on the tainted node

```sh
kubectl get pods -n mysql -o wide
```

Expected:

* `mysql-0` is running on `kind-worker2`

---

### 3. Check ToDo App Pods Spread with Anti-Affinity

```sh
kubectl get pods -n todoapp -o wide
```

Expected:

* Multiple `todoapp` pods are running on **different** nodes
* No more than one `todoapp` pod per node

---

### 4. Inspect ToDo Deployment Affinity and Tolerations

```sh
kubectl get deployment todoapp -n todoapp -o yaml
```

Ensure the following is present in the output:

* `nodeAffinity` with `preferredDuringSchedulingIgnoredDuringExecution` targeting nodes with `app=todoapp`
* `podAntiAffinity` to avoid running multiple `todoapp` pods on the same node
* `tolerations` to allow pods to be scheduled on nodes tainted with `app=mysql:NoSchedule`

---

### 5. Ingress (Optional)

If you deployed an ingress controller, verify that it's working:

```sh
curl http://localhost/api/todos/
```

Expected: valid JSON response from the API.

---

### Done!

Once validated, create a Pull Request and attach it on the platform for review.
