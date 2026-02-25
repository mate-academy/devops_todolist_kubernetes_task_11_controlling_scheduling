# Validation Guide

## Prerequisites

- `docker` is running
- `kind` is installed
- `kubectl` is installed
- You are in the project root

## 1. Bootstrap the cluster and deploy everything

```bash
./bootstrap.sh
```

What this script does:
- Deletes existing kind clusters first (can be disabled with `CLEAN_EXISTING_KIND_CLUSTERS=false`)
- Creates a kind cluster from `cluster.yml`
- Waits until all nodes are `Ready`
- Prints node labels
- Taints nodes with label `app=mysql` using `app=mysql:NoSchedule`
- Deploys MySQL and todoapp resources
- Installs ingress-nginx and applies ingress resource

## 2. Validate node labels and taints

Check labels:

```bash
kubectl get nodes -L app
```

Check taints on mysql nodes:

```bash
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Expected:
- MySQL nodes have label `app=mysql`
- MySQL nodes have taint `app=mysql:NoSchedule`

## 3. Validate StatefulSet scheduling rules (mysql)

Check StatefulSet spec:

```bash
kubectl -n mysql get statefulset mysql -o yaml
```

Expected in spec:
- `tolerations` for `app=mysql:NoSchedule`
- `nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` for `app=mysql`
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` on `kubernetes.io/hostname`

Check pod placement:

```bash
kubectl -n mysql get pods -l app=mysql -o wide
```

Expected:
- All mysql pods run only on nodes labeled `app=mysql`
- mysql replicas are on different nodes

Optional quick check for unique node count:

```bash
kubectl -n mysql get pods -l app=mysql -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort -u | wc -l
```

Expected output: `2` (for `replicas: 2`)

## 4. Validate Deployment scheduling rules (todoapp)

Check Deployment spec:

```bash
kubectl -n todoapp get deployment todoapp -o yaml
```

Expected in spec:
- `nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for `app=todoapp`
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` on `kubernetes.io/hostname`

Scale deployment to verify anti-affinity behavior:

```bash
kubectl -n todoapp scale deployment todoapp --replicas=2
kubectl -n todoapp rollout status deployment/todoapp
kubectl -n todoapp get pods -l app=todoapp -o wide
```

Expected:
- todoapp pods are on different nodes
- pods prefer nodes labeled `app=todoapp`

## 5. Validate app reachability

NodePort check:

```bash
curl -i http://localhost:30007/api/health
```

Expected: HTTP `200` response.

Ingress check (wait until ingress controller is Ready):

```bash
curl -i http://localhost:8080/api/health
```

## 6. Cleanup

```bash
kind delete cluster --name todolist-scheduling
```

## 7. Troubleshooting

If bootstrap fails because of existing kind clusters, run:

```bash
kind get clusters
kind delete cluster --name kind
```

Then run bootstrap again:

```bash
./bootstrap.sh
```
