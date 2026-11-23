# Validate the changes

### Create the cluster and deploy everything:

```bash
chmod +x bootstrap.sh && ./bootstrap.sh
```

### Check node labels and taints:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}app={.metadata.labels.app}{"\t"}{.spec.taints}{"\n"}{end}'
```

### Check pod placement:

```bash
kubectl get pods -A -o wide
```
> - MySQL pods run only on `app=mysql` nodes, one per node.
> - ToDo app pods run on `app=todoapp` nodes, one per node.

### Check the StatefulSet has the toleration, the node affinity (`app=mysql`) and the pod anti-affinity:

```bash
kubectl get statefulset mysql -n mysql -o yaml | grep -E -A12 "affinity:|tolerations:"
```

### Check the Deployment has the preferred node affinity (`app=todoapp`) and the pod anti-affinity:

```bash
kubectl get deployment todoapp -n todoapp -o yaml | grep -A25 "affinity:"
```