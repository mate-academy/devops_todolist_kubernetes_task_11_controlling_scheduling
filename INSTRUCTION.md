# INSTRUCTION.md

## Deploy the cluster

```bash
kind create cluster --config cluster.yml
chmod +x bootstrap.sh
./bootstrap.sh
```

## Note

The ToDo application is deployed using a Kubernetes **Deployment**, which creates and manages the application Pods. No standalone Pod manifest is provided.

## Validate the deployment

### Verify nodes, labels and taints

```bash
kubectl get nodes --show-labels
kubectl describe nodes
```

Confirm that the node labeled `app=mysql` has the following taint:

```
app=mysql:NoSchedule
```

### Verify workloads

```bash
kubectl get pods -A -o wide
kubectl get deployment -A
kubectl get statefulset -A
```

### Verify scheduling

Ensure that:

- MySQL Pods are scheduled only on nodes labeled `app=mysql`.
- ToDo application Pods are scheduled on nodes labeled `app=todoapp`.
- Replicas of both workloads are running on different nodes (Pod Anti-Affinity).

Verify pod placement:

```bash
kubectl get pods -A -o wide
```

## Access the ToDo application

The application is exposed through the **NGINX Ingress Controller** installed by `bootstrap.sh`.

Get the Ingress resource:

```bash
kubectl get ingress -A
```

If Ingress is not accessible in your environment, use port forwarding instead:

```bash
kubectl port-forward -n todoapp svc/todoapp 8080:80
```

Then open:

```
http://localhost:8080
```