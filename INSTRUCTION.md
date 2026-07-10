# INSTRUCTION.md

## Deploy the cluster

```bash
kind create cluster --config cluster.yml
chmod +x bootstrap.sh
./bootstrap.sh
```

## Project resources

The project contains the following manifests:

- `todoapp-pod-1.yml` – standalone Pod manifest for the ToDo application (required by the assignment).
- `todoapp-deployment.yml` – Deployment used to demonstrate node affinity and pod anti-affinity.
- `mysql-statefulset.yml` – StatefulSet with tolerations, required node affinity and pod anti-affinity.

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
- ToDo Deployment Pods are scheduled on nodes labeled `app=todoapp`.
- Pod Anti-Affinity distributes replicas across different nodes.

Verify pod placement:

```bash
kubectl get pods -A -o wide
```

## Access the ToDo application

The application is exposed through the NGINX Ingress Controller installed by `bootstrap.sh`.

Check the Ingress resource:

```bash
kubectl get ingress -A
```

If Ingress is unavailable, use port forwarding:

```bash
kubectl port-forward -n todoapp svc/todoapp 8080:80
```

Then open:

```
http://localhost:8080
```