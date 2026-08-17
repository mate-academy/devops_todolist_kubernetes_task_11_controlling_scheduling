# Kubernetes ToDo App — Validation Instructions

## 1. Create the Kind cluster

```bash
kind create cluster --config cluster.yml
```

## 2. Inspect node labels

Check the `app` labels:

```bash
kubectl get nodes -L app
```

## 3. Apply the MySQL taint

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

Verify the taints:
```bash
kubectl get nodes -o custom-columns="NAME:.metadata.name,APP:.metadata.labels.app,TAINTS:.spec.taints"
```

The MySQL nodes must contain:
```text
app=mysql:NoSchedule
```

## 4. Deploy the application
```bash
bash bootstrap.sh
```

## 5. Validate the StatefulSet

Check the StatefulSet:
```bash
kubectl get statefulsets -A
```

Check MySQL pods:
```bash
kubectl get pods -A -o wide
```

Check the pod's node:
```bash
kubectl get pods -o wide -n todoapp
```

## 6. Validate MySQL pod anti-affinity

Check the StatefulSet configuration:
```bash
kubectl get statefulset -o yaml -n todoapp
```

Check the actual nodes:
```bash
kubectl get pods -o wide -n todoapp
```

## 7. Validate the ToDo Deployment

Check the Deployment:

```bash
kubectl get deployments -A
```

Check its pods and nodes:

```bash
kubectl get pods -o wide -n todoapp
```

## 8. Validate ToDo pod anti-affinity

Check the Deployment:
```bash
kubectl get deployment -o yaml -n todoapp
```

Check the actual placement:
```bash
kubectl get pods -o wide -n todoapp
```
