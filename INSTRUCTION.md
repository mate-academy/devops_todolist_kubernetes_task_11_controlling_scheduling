# Validation instructions

## Prerequisites

1. Install and configure `docker`, `kubectl`, and `kind`.
1. Change directory to the project root:

```bash
cd devops_todolist_kubernetes_task_11_controlling_scheduling
```

## Deploy all resources

1. Run bootstrap:

```bash
bash bootstrap.sh
```

This script will:
- recreate a `kind` cluster named `todoapp` using `cluster.yml`
- inspect node labels and taints
- taint all nodes labeled `app=mysql` with `app=mysql:NoSchedule`
- deploy mysql and todoapp resources
- deploy ingress-nginx and apply ingress

## Validate node labels and taints

1. Check labels:

```bash
kubectl get nodes --show-labels
```

Expected result:
- at least two nodes include `app=mysql`
- at least three nodes include `app=todoapp`

1. Check taints:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Expected result:
- every node labeled `app=mysql` contains `app=mysql:NoSchedule`

## Validate MySQL StatefulSet scheduling rules

1. Confirm StatefulSet pods are running:

```bash
kubectl -n mysql get pods -o wide
```

Expected result:
- `mysql-0` and `mysql-1` are `Running`
- each pod is on a different node

1. Verify toleration exists:

```bash
kubectl -n mysql get pod mysql-0 -o jsonpath='{.spec.tolerations}'
```

Expected result:
- includes key `app`, value `mysql`, effect `NoSchedule`

1. Verify node affinity exists:

```bash
kubectl -n mysql get statefulset mysql -o jsonpath='{.spec.template.spec.affinity.nodeAffinity}'
```

Expected result:
- includes required rule for label `app In [mysql]`

1. Verify pod anti-affinity exists:

```bash
kubectl -n mysql get statefulset mysql -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}'
```

Expected result:
- includes required anti-affinity for pods labeled `app=mysql` with topology key `kubernetes.io/hostname`

## Validate ToDo deployment scheduling rules

1. Confirm deployment pods are running:

```bash
kubectl -n todoapp get pods -l app=todoapp -o wide
```

Expected result:
- pods are `Running`
- pods are spread across different nodes

1. Verify preferred node affinity exists:

```bash
kubectl -n todoapp get deployment todoapp -o jsonpath='{.spec.template.spec.affinity.nodeAffinity}'
```

Expected result:
- includes `preferredDuringSchedulingIgnoredDuringExecution`
- preference matches `app In [todoapp]`

1. Verify pod anti-affinity exists:

```bash
kubectl -n todoapp get deployment todoapp -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}'
```

Expected result:
- includes required anti-affinity for pods labeled `app=todoapp` with topology key `kubernetes.io/hostname`

## Optional runtime validation

1. Check service access:

```bash
kubectl -n todoapp get svc
```

1. Check ingress:

```bash
kubectl get ingress -A
```

1. Check events if a pod is pending:

```bash
kubectl -n mysql describe pod mysql-0
kubectl -n todoapp describe pod <todoapp-pod-name>
```

## Cleanup

```bash
kind delete cluster --name todoapp
```
