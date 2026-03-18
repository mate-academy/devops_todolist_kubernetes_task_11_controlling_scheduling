## Kubernetes task 11 — Controlling scheduling

### 1) Create kind cluster

```bash
kind create cluster --config cluster.yml
```

### 2) Inspect node labels/taints (before bootstrap)

```bash
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "Taints:|Name:"
```

Expected:
- There are nodes labeled `app=mysql`
- There are nodes labeled `app=todoapp`
- Initially `app=mysql` nodes are expected to have no `app=mysql:NoSchedule` taint

### 3) Deploy manifests + apply taint

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

### 4) Validate taint

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.taints}{"\n"}{end}'
```

Expected:
- Nodes with label `app=mysql` should contain taint `app=mysql:NoSchedule`

### 5) Validate StatefulSet scheduling (MySQL)

Check MySQL pods on which nodes they run:

```bash
kubectl -n mysql get pods -o wide -l app=mysql
```

Expected:
- Each MySQL pod is running on nodes that have label `app=mysql`
- MySQL pods are running on different nodes (pod anti-affinity)

If pods can’t schedule, check events:

```bash
kubectl -n mysql describe pod <POD_NAME>
```

### 6) Validate Deployment scheduling (todoapp)

HPA should ensure at least 2 replicas, so after a short wait:

```bash
kubectl -n todoapp get hpa
kubectl -n todoapp get pods -o wide -l app=todoapp
```

Expected:
- Todo app pods are running on nodes that have label `app=todoapp`
- Todo app pods are running on different nodes (pod anti-affinity)

