### 1. Create cluster from file config:
```bash
kind create cluster --config cluster.yml
```

### 2. Validate cluster's taints:
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```
### 3. Validate cluster's labels:
```bash
kubectl get nodes --show-labels
```

### 4. Taint nodes labeled with app=mysql with app=mysql:NoSchedule...
```bash
kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule
```

### 5. Run script to set up databases, apps, ingress:
```bash
./bootstrap.sh
```
### 6. Validate that the application and DBs are running
Check the status of the pods:
```bash
kubectl get pods -n todoapp -o wide
```
