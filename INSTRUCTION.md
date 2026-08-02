# Instructions for verifying the correctness of the changes made.

1. Check all the taints on the nodes 
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```

2. Review all existing pods in our namespaces
```bash
kubectl get pods -n mysql
```

```bash
kubectl get pods -n todoapp
```

3. Substitute each pod into the next command
```bash
kubectl get pod <pod-name> -n mysql -o yaml
```

```bash
kubectl get pod <pod-name> -n todoapp -o yaml
```

4. Look at the affinity section, which contains the nodeAffinity and podAntiAffinity rules