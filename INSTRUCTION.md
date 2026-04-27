# Validation

- Check all pods

```sh
kubectl get nodes --show-labels
kubectl describe nodes | grep -i taints
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
kubectl describe statefulset mysql -n mysql
kubectl describe deployment todoapp -n todoapp
```

if you see mysql pods on worker, worker2 and todoapp pods only on worker3, worker4, worker5, worker6 All changes applied successfully
