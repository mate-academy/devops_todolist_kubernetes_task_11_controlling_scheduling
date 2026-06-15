# Task 11 — Controlling Scheduling: Validation Instructions

This document explains how to deploy and validate the scheduling rules added in this task.

## What changed

| File | Change |
| --- | --- |
| `bootstrap.sh` | Creates the kind cluster, **taints the `app=mysql` nodes** with `app=mysql:NoSchedule`, then deploys all resources. |
| `.infrastructure/mysql/statefulSet.yml` | Added a **toleration** for `app=mysql:NoSchedule`, **required node affinity** to `app=mysql` nodes, and **required pod anti-affinity** (one MySQL pod per node). |
| `.infrastructure/app/deployment.yml` | Added **preferred node affinity** to `app=todoapp` nodes and **required pod anti-affinity** (one todoapp pod per node). |

### Cluster topology (`cluster.yml`)

- 1 control-plane
- 2 workers labeled `app=mysql`  → tainted `app=mysql:NoSchedule`
- 3 workers labeled `app=todoapp`
- 1 unlabeled worker

## Prerequisites

- [Docker](https://www.docker.com/) running
- [kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Deploy

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script is idempotent — it reuses an existing `todoapp` cluster and re-applies the taint with `--overwrite`.

To start completely fresh:

```bash
kind delete cluster --name todoapp
./bootstrap.sh
```

## Validation

### 1. Inspect node labels

```bash
kubectl get nodes -L app
```

Expected: two nodes show `mysql`, three show `todoapp`, and the remaining worker(s) show no value under the `APP` column.

### 2. Verify the taint on the MySQL nodes

```bash
kubectl get nodes -l app=mysql \
  -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Expected: each `app=mysql` node lists a taint `app=mysql:NoSchedule`.

### 3. Verify MySQL (StatefulSet) scheduling

```bash
kubectl get pods -n mysql -o wide
```

Expected:
- 2 MySQL pods, both **Running**.
- Each pod is on a **different** node (pod anti-affinity).
- Both nodes are labeled `app=mysql` (node affinity + toleration let them land on the tainted nodes).

Confirm the nodes hosting MySQL carry the `app=mysql` label:

```bash
for n in $(kubectl get pods -n mysql -o jsonpath='{.items[*].spec.nodeName}'); do
  kubectl get node "$n" -L app --no-headers
done
```

### 4. Verify ToDo app (Deployment) scheduling

```bash
kubectl get pods -n todoapp -o wide
```

Expected:
- Pods are **Running**.
- No two todoapp pods share a node (required pod anti-affinity).
- Pods prefer the `app=todoapp` nodes; none are scheduled onto the tainted `app=mysql` nodes (no matching toleration).

### 5. Confirm the rules are present in the running objects

```bash
kubectl get statefulset mysql -n mysql \
  -o jsonpath='{.spec.template.spec.tolerations}{"\n"}{.spec.template.spec.affinity}{"\n"}'

kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.affinity}{"\n"}'
```

### 6. (Optional) Prove the taint / anti-affinity actually block scheduling

Anti-affinity test — scale beyond the number of eligible nodes and watch a pod stay `Pending`
(`requiredDuringScheduling` allows at most one pod per node):

```bash
kubectl scale statefulset mysql -n mysql --replicas=3
kubectl get pods -n mysql -o wide        # the 3rd pod stays Pending
kubectl describe pod mysql-2 -n mysql    # Events show the anti-affinity / taint reason
kubectl scale statefulset mysql -n mysql --replicas=2   # revert
```

> **Note on the Deployment + HPA:** the HPA (`hpa.yml`) allows up to 5 replicas, but the
> required pod anti-affinity caps todoapp at one pod per eligible (untainted) node — there are
> 4 such nodes (3 `app=todoapp` + 1 unlabeled). A 5th replica would remain `Pending` by design.
> Switch the deployment's `podAntiAffinity` to `preferredDuringSchedulingIgnoredDuringExecution`
> if you need it to scale to the full HPA maximum.

## Cleanup

```bash
kind delete cluster --name todoapp
```
