### Exec in your terminal:

```bash
./bootstrap.sh
```

### Verify Nodes
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
kubectl get nodes --show-labels
```

### Verify Pods
```bash
kubectl get pod -n mysql 
kubectl get pod -n todoapp 
```