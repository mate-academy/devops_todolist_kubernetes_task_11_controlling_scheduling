### 1 Create the cluster

From repo root:

```
kind create cluster --name todo --config cluster.yml
```

Check nodes:

```
kubectl get nodes -o wide
```

### 2 Verify labels and taints (before tainting)

```
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

### 3 Taint nodes labeled app=mysql

```
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

Verify taints:

```
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

### 4 Deploy all resources

Use the bootstrap script:

```
./bootstap.sh
```

### 5 Validate MySQL scheduling rules

Confirm MySQL pods are only on `app=mysql` nodes and not co-located:

```
kubectl get pods -n mysql -o wide
```

Check the pod spec includes tolerations and affinities:

```
kubectl get statefulset mysql -n mysql -o yaml | Select-String -Pattern "tolerations|affinity"
```

Expected:

- Each MySQL pod is on a different node (anti-affinity).
- Nodes are tainted `app=mysql:NoSchedule` but MySQL pods still schedule (toleration).
- Nodes used for MySQL have label `app=mysql` (node affinity).

### 6 Validate Todoapp scheduling rules

Confirm todoapp pods prefer `app=todoapp` nodes and are not co-located:

```
kubectl get pods -n todoapp -o wide
```

Check the pod spec includes affinity rules:

```
kubectl get deployment todoapp -n todoapp -o yaml | Select-String -Pattern "affinity"
```

Expected:

- Pods are spread across different nodes (anti-affinity).
- Pods prefer nodes labeled `app=todoapp` (preferred node affinity).
