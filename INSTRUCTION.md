# Task 11: Controlling Scheduling (Taints, Tolerations, Affinity)

## Requirements

- Docker Desktop
- kind
- kubectl
- Git Bash (or any bash shell)

## How to run

Create the cluster and deploy everything with one command:

```bash
bash bootstrap.sh
```

The script does the following:

1. Creates a kind cluster from `cluster.yml`: 1 control-plane node, 2 workers labeled `app=mysql`, 3 workers labeled `app=todoapp` and 1 worker without the `app` label.
2. Waits until all nodes are Ready.
3. Taints the nodes labeled `app=mysql` with `app=mysql:NoSchedule`.
4. Applies the MySQL manifests (namespace, ConfigMap, Secret, Service, StatefulSet).
5. Applies the app manifests (namespace, PV, PVC, Secret, ConfigMap, Services, HPA, Deployment).

## Scheduling rules

MySQL StatefulSet (`.infrastructure/mysql/statefulSet.yml`):

- Toleration for `app=mysql:NoSchedule`, so pods can run on the tainted nodes.
- Required node affinity: only nodes with the label `app=mysql`.
- Required pod anti-affinity (`topologyKey: kubernetes.io/hostname`): two MySQL pods are never scheduled on the same node.

Todoapp Deployment (`.infrastructure/app/deployment.yml`):

- Preferred node affinity (`preferredDuringSchedulingIgnoredDuringExecution`, weight 100) for nodes labeled `app=todoapp`.
- Required pod anti-affinity (`topologyKey: kubernetes.io/hostname`): two todoapp pods are never scheduled on the same node.

## How to validate

1. All nodes are Ready and have the expected labels:

```bash
kubectl get nodes --show-labels
```

2. Only the two `app=mysql` nodes have the taint `app=mysql:NoSchedule` (the control-plane has its default taint):

```bash
kubectl describe nodes | grep -E "^Name:|Taints:"
```

3. Check where the pods are running (wait 2-3 minutes until all pods are Running):

```bash
kubectl get pods -A -o wide | grep -E "mysql|todoapp"
```

Expected result:

- `mysql-0` and `mysql-1` are Running on two different nodes with the label `app=mysql` (`kind-worker` and `kind-worker2`).
- The `todoapp` pods are Running on different nodes. Normally they are on the `app=todoapp` nodes.

## Notes

- The HPA allows up to 5 replicas, but the required pod anti-affinity allows only one todoapp pod per node, and only 4 nodes are available for the app (the 2 `app=mysql` nodes are tainted, the control-plane is tainted too). A fifth pod would stay Pending. This is expected.
- The first todoapp pod may restart once during startup, because it starts before MySQL is ready.
- Passwords in the Secrets are demo values for a local cluster only.
