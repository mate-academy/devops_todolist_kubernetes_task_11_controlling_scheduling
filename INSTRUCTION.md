# INSTRUCTION.md

## Validation of Kubernetes Deployment

This document describes the **minimum required steps** to validate that all changes were applied correctly.

---

## 1. Deploy all resources

Run the bootstrap script:

```sh
./bootstrap.sh
```

Ensure it finishes without errors.

---

## 2. Verify namespaces

```sh
kubectl get ns
```

Expected namespaces (example):

* todoapp
* mysql

---

## 3. Validate Deployments and StatefulSets

```sh
kubectl get deploy -n todoapp
kubectl get statefulset -n mysql
```

Ensure all replicas are **READY**.

---

## 4. Validate Pod scheduling rules

### Check node labels

```sh
kubectl get nodes --show-labels
```

Ensure nodes have the required labels (e.g. `app=todoapp`, `app=mysql`).

### Check node taints

```sh
kubectl describe node <node-name> | grep Taints
```

Ensure taints match the tolerations defined in the manifests.

### Check pod scheduling result

```sh
kubectl get pods -o wide -n todoapp
kubectl get pods -o wide -n mysql
```

Verify pods are scheduled on expected nodes.

### Check Pod Anti-Affinity

Ensure that pods of the same app are **not running on the same node**.

---

## 5. Validate HPA

```sh
kubectl get hpa -n todoapp
```

Expected:

* MINPODS = 2
* MAXPODS = 5
* CPU and MEMORY metrics present

---

## 6. Validate application availability

```sh
kubectl get svc -n todoapp
```

Use the service endpoint (NodePort / Ingress) to access the application.

---

## 7. Validate rollout strategy

```sh
kubectl rollout status deploy/todoapp -n todoapp
```

Ensure rolling update completes without downtime.

---

## Result

If all commands above return expected results, the deployment is considered **valid and successful**.
