### 1. Run script to set up databases, apps, ingress:
```bash
./bootstrap.sh
```

### 2. Validate cluster's labels:
```bash
kubectl get nodes --show-labels
```

### 3. Validate that the application and DBs are running
Check the status of the pods:
```bash
kubectl get pods -n todoapp -o wide
```
