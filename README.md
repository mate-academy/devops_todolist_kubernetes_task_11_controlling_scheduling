## Validate the changes

Pod Scheduling

```bash
kubectl get pods -o wide
```

Pod Details

```bash
kubectl describe pod <pod-name>
```

Node Affinity

```bash
kubectl get nodes --show-labels
```

Taints and Toleration

```bash
kubectl describe node <node-name>
```

Pod Distribution

```bash
kubectl get pods -o wide
```
