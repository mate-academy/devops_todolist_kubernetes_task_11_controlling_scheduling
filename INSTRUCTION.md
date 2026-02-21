# Validation Instructions for Task 11: Controlling Scheduling

Python 3.8+ is required to run the app locally (pip install -r requirements.txt; python manage.py migrate; python manage.py runserver)

This document describes how to verify that the Kubernetes resources are correctly deployed and that the scheduling constraints (Affinity, Taints, and Tolerations) are working as expected.
Before validation, you must deploy all resources using the provided automation script:
**Make the script executable:**
```bash
   chmod +x bootstrap.sh
   ./bootstrap.sh
```
./bootstrap.sh creates the cluster from cluster.yml
---

## 1. Prerequisites
* The Kind cluster is running with the configuration from `cluster.yml`.
* Docker Desktop is active.
* All resources have been deployed using `./bootstrap.sh`.

---

## 2. Validation Steps

### Step 1: Verify Node Labels
Check if the nodes have the correct labels applied during cluster creation:
```bash
kubectl get nodes --show-labels
```
Expected Result:

kind-worker and kind-worker2 should have the label app=mysql. ✅
kind-worker3, kind-worker4, and kind-worker5 should have the label app=todoapp. ✅

## 3. Verify MySQL Scheduling (Taints & Tolerations)
Check if the MySQL pods are running on the specific tainted nodes:
```bash
kubectl get pods -n mysql -o wide
```

Expected Result:

mysql-0 should be scheduled on kind-worker. ✅
mysql-1 should be scheduled on kind-worker2. ✅
Both pods must be in Running status. ✅

To confirm the taints are active on these nodes:

```bash
kubectl describe nodes | grep Taints
```

## 4. Verify Todoapp Scheduling (Affinity)

Check the distribution of the todoapp replicas across the worker nodes:

```bash
kubectl get pods -n todoapp -o wide
```
Expected Result:
There should be 3 replicas running. ✅
Each pod must be on a different node (kind-worker3, kind-worker4, kind-worker5) due to the Pod Anti-Affinity rule. ✅
No two todoapp pods should share the same hostname. ✅