# Kubernetes scheduling validation

This guide validates the kind cluster, node scheduling rules, and deployed
resources required by the task.

## Prerequisites

Install and start:

- Docker;
- `kind`;
- `kubectl`.

Run all commands from the repository root.

## Deploy the environment

Make the bootstrap script executable and run it:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script creates the `kind` cluster from `cluster.yml` when it does not
exist. On subsequent runs, it reuses the cluster and reapplies its
configuration and Kubernetes resources.

## Validate the nodes

Confirm that all nodes are ready:

```bash
kubectl get nodes
```

Inspect labels:

```bash
kubectl get nodes -L app
```

Expected scheduling labels:

- `kind-worker` and `kind-worker2` have `app=mysql`;
- `kind-worker3`, `kind-worker4`, and `kind-worker5` have `app=todoapp`.

Inspect taints:

```bash
kubectl get nodes \
  -o custom-columns='NAME:.metadata.name,TAINTS:.spec.taints'
```

Both MySQL nodes must contain `app=mysql:NoSchedule`.

## Validate MySQL scheduling

Inspect the StatefulSet scheduling configuration:

```bash
kubectl get statefulset mysql -n mysql \
  -o jsonpath='{.spec.template.spec.tolerations}{"\n"}'
kubectl get statefulset mysql -n mysql \
  -o jsonpath='{.spec.template.spec.affinity.nodeAffinity}{"\n"}'
kubectl get statefulset mysql -n mysql \
  -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}{"\n"}'
```

The output must show:

- a toleration for `app=mysql:NoSchedule`;
- required `nodeAffinity` for the `app=mysql` node label;
- required `podAntiAffinity` with topology key `kubernetes.io/hostname`.

Check Pod placement:

```bash
kubectl get pods -n mysql -o wide
```

Expected result:

- two MySQL Pods are `Running` and ready;
- both run only on nodes labeled `app=mysql`;
- `mysql-0` and `mysql-1` run on different nodes.

Check the rollout and persistent volumes:

```bash
kubectl rollout status statefulset/mysql -n mysql --timeout=300s
kubectl get pvc -n mysql
```

If an old Pending Pod still contains outdated scheduling rules, reapply the
manifest and recreate only that Pod:

```bash
kubectl apply -f .infrastructure/mysql/statefulSet.yml
kubectl delete pod <pending-pod-name> -n mysql
```

Do not delete its PVC.

## Validate Todo application scheduling

Inspect Deployment affinity:

```bash
kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.affinity.nodeAffinity}{"\n"}'
kubectl get deployment todoapp -n todoapp \
  -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}{"\n"}'
```

The output must show:

- preferred `nodeAffinity` for nodes labeled `app=todoapp`;
- required `podAntiAffinity` with topology key `kubernetes.io/hostname`.

Check the rollout and Pod placement:

```bash
kubectl rollout status deployment/todoapp -n todoapp --timeout=300s
kubectl get pods -n todoapp -o wide
```

The Todo Pods must run on different nodes. When suitable capacity is
available, the scheduler should prefer nodes labeled `app=todoapp`.
Unlike required affinity, preferred affinity does not make other nodes
ineligible.

## Validate application resources

List all resources:

```bash
kubectl get all -n mysql
kubectl get all -n todoapp
kubectl get pvc -n mysql
kubectl get pvc -n todoapp
kubectl get ingress -n todoapp
```

Check the HorizontalPodAutoscaler:

```bash
kubectl get hpa todoapp -n todoapp
```

The metrics may temporarily display `<unknown>` if Metrics Server is not
installed in the kind cluster. This does not prevent the Deployment from
running.

Check Services and endpoints:

```bash
kubectl get service,endpoints -n mysql
kubectl get service,endpoints -n todoapp
```

## Test application access

The kind control-plane maps host port `30007` to the Todo NodePort:

```bash
curl -I http://localhost:30007/
```

The ingress controller maps host port `80`:

```bash
curl -I http://localhost/
```

An HTTP response confirms connectivity; the exact status code depends on the
application route.

## Troubleshooting

Show recent scheduling and workload events:

```bash
kubectl get events -n mysql --sort-by=.lastTimestamp
kubectl get events -n todoapp --sort-by=.lastTimestamp
```

Describe a Pending or unhealthy Pod:

```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

Verify the applied affinity and tolerations directly:

```bash
kubectl get pod <pod-name> -n <namespace> -o yaml
```

Common scheduler messages:

- `didn't match Pod's node affinity/selector` means the node labels do not
  satisfy required node affinity;
- `had untolerated taint(s)` means the Pod lacks a matching toleration;
- Pod anti-affinity scheduling failures mean no eligible node can satisfy the
  requirement to place matching Pods on different hostnames.
