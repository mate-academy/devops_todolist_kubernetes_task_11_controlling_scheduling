# Task 11 — Kubernetes Scheduling: Validation Instructions

## Prerequisites

Install and start Docker Desktop, and install `kind`, `kubectl`, and Bash. Run all commands from the root of this repository. Allocate enough Docker Desktop CPU and memory for five Kubernetes nodes, MySQL, and Django.

The repository's `cluster.yml` must define **one control-plane node and four worker nodes**. The bootstrap script uses a kind cluster named `scheduling`, expects exactly four workers, and can be rerun without recreating an existing cluster.

**Port conflicts:** The scheduling exercise does not require host port mappings. If another local kind cluster uses ports 80, 443, 30007, or 30008, remove the conflicting `extraPortMappings` from this task's `cluster.yml` before starting. Do not delete unrelated clusters.

## 1. Create the cluster and deploy resources

From the repository root, run:

```bash
bash bootstrap.sh
```

The script must:

1. Check whether the `scheduling` kind cluster exists. If absent, create it using `cluster.yml`.
2. Select the `kind-scheduling` context and wait for all nodes to become `Ready`.
3. **Inspect existing node labels and taints before modifying them**, using `kubectl get nodes --show-labels` and `kubectl describe nodes`.
4. Label three worker nodes `app=mysql` and taint them `app=mysql:NoSchedule`.
5. Label the fourth worker node `app=todoapp`.
6. Display the updated labels and taints.
7. Apply MySQL Namespace, ConfigMap, Secret, Service, and StatefulSet, and wait for the StatefulSet rollout.
8. Apply Django Namespace, storage, Secret, ConfigMap, Services, and Deployment, and wait for the Deployment rollout.
9. Display the final node and Pod placement.

The **HPA is intentionally not installed** in this task. Its previous minimum of two replicas conflicts with the available Django scheduling capacity when required Pod anti-affinity is enabled. On a fresh cluster, no HPA should exist in the `todoapp` namespace.

A successful run ends with `Deployment completed.`. To check the selected cluster:

```bash
kubectl config current-context
kubectl get nodes -o wide
```

Expected: context `kind-scheduling`; five `Ready` nodes. The exact node names begin with `scheduling-` when this cluster name is used.

## 2. Verify node labels and taints

```bash
kubectl get nodes --show-labels
kubectl get nodes -L app
kubectl describe nodes | grep -E '^Name:|^Taints:'
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.taints}{"\n"}{end}'
```

Expected:

- Three workers have label `app=mysql` and taint `app=mysql:NoSchedule`.
- One worker has label `app=todoapp` and no MySQL taint.
- The control-plane retains its `node-role.kubernetes.io/control-plane:NoSchedule` taint.

The bootstrap script assigns roles based on a sorted list of worker names. Do not rely on the same worker numbering when testing with another cluster name.

## 3. Verify MySQL StatefulSet scheduling

```bash
kubectl get statefulset mysql -n mysql
kubectl get pods -n mysql -o wide
kubectl get pvc -n mysql
kubectl get statefulset mysql -n mysql -o yaml
```

The StatefulSet uses **two replicas**. Wait for `mysql-0` and `mysql-1` to become `1/1 Running`. They must be on **different** worker nodes that have `app=mysql` labels.

Under `spec.template.spec`, verify:

- `tolerations`: `key: app`, `operator: Equal`, `value: mysql`, `effect: NoSchedule`.
- `nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution`: selects nodes labeled `app=mysql`.
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution`: selects Pods labeled `app=mysql`, using `topologyKey: kubernetes.io/hostname`.

A toleration allows a Pod to use a tainted node; required node affinity restricts eligible nodes; required Pod anti-affinity prevents two matching MySQL Pods from sharing a node.

## 4. Verify Django Deployment scheduling

```bash
kubectl get deployment todoapp -n todoapp
kubectl get pods -n todoapp -o wide
kubectl get deployment todoapp -n todoapp -o yaml
kubectl get hpa -n todoapp
```

Under `spec.template.spec.affinity`, verify:

- `nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` has a preference for the node label `app=todoapp` (weight `100` in this implementation).
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` selects Pods labeled `app=todoapp`, using `topologyKey: kubernetes.io/hostname`.

Expected on this cluster: one Django Pod becomes `1/1 Running`, normally on the worker labeled `app=todoapp`. Preferred affinity influences selection but does not guarantee a particular node. The HPA query should report no resources on a fresh deployment.

If Django starts as `0/1 Running`, it may still be initializing or running database migrations. Check its status and logs:

```bash
kubectl get pods -n todoapp -o wide
kubectl logs -n todoapp deployment/todoapp --tail=80
```

Wait for readiness. Check Pod events if it does not recover.

## 5. Optional: demonstrate required Pod anti-affinity

First confirm that no HPA is managing the Deployment:

```bash
kubectl get hpa -n todoapp
```

If an HPA remains from an **earlier run in this same learning cluster**, remove it before the test:

```bash
kubectl delete hpa todoapp -n todoapp
```

Temporarily request two Django replicas:

```bash
kubectl scale deployment/todoapp -n todoapp --replicas=2
kubectl get pods -n todoapp -o wide
```

In the intended four-worker setup, expect one Django Pod to run and the second to remain `Pending`: required Pod anti-affinity prevents co-location on the same node, while the other three worker nodes have MySQL taints that Django does not tolerate. Confirm the actual scheduling reason in the Pending Pod's events:

```bash
kubectl get pods -n todoapp
kubectl describe pod PENDING_POD_NAME -n todoapp
```

Replace `PENDING_POD_NAME` with the real name from `kubectl get pods`; do not copy that placeholder literally.

Restore one replica after the test:

```bash
kubectl scale deployment/todoapp -n todoapp --replicas=1
kubectl get pods -n todoapp -o wide
```

The second Pod may briefly show `Terminating` before disappearing.

## 6. Troubleshooting

For Pods stuck in `Pending`, inspect node constraints and scheduler events:

```bash
kubectl get pods -A -o wide
kubectl get nodes -L app
kubectl describe nodes | grep -E '^Name:|^Taints:'
kubectl describe pod POD_NAME -n NAMESPACE
```

Replace `POD_NAME` and `NAMESPACE` with actual values. Common causes include untolerated taints, missing node labels, insufficient requested resources, and required Pod anti-affinity conflicts.

A Pod that is `Running` but not `Ready` has passed scheduling, but may have a failing application readiness probe. Check its logs and events instead of changing affinity rules immediately.

If `bootstrap.sh` fails at cluster creation, inspect the `cluster.yml` YAML syntax, node count, Docker Desktop resources, and any conflicting published host ports. If it times out waiting for Django, check whether an old HPA has created more replicas than the available nodes can accommodate.

## 7. Submission

Confirm the Pull Request includes the modified MySQL StatefulSet, Django Deployment, `bootstrap.sh`, and this `INSTRUCTION.md`. Keep secrets, virtual environments, IDE settings, and local cluster state out of the commit.

```bash
git status
git add .infrastructure/mysql/statefulSet.yml .infrastructure/app/deployment.yml bootstrap.sh INSTRUCTION.md
git diff --cached --stat
git commit -m "Configure Kubernetes scheduling and bootstrap validation"
git push origin HEAD
```

If `cluster.yml` was modified to make the task's five-node cluster reproducible, review and include that change as well. Open or update the Pull Request and submit its URL on the Mate Academy platform.

**Validation note:** Rerunning `bootstrap.sh` on an existing cluster tests idempotent application of resources, but does **not** test the cluster-creation branch. A reviewer should also validate the full flow on a fresh cluster when possible.
