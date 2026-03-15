# Validation Guide

## 1. Create the cluster and deploy the manifests

Run:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script recreates the `kind` cluster named `todoapp-scheduling`, taints the MySQL worker nodes, installs ingress-nginx, and applies all Kubernetes manifests.

## 2. Validate node labels and taints

Check labels:

```bash
kubectl get nodes --show-labels
kubectl get nodes -l app=mysql
kubectl get nodes -l app=todoapp
```

Check taints on the MySQL nodes:

```bash
kubectl describe nodes -l app=mysql | grep -A3 Taints
```

Expected result:

- Nodes labeled with `app=mysql` have the taint `app=mysql:NoSchedule`.
- Nodes labeled with `app=todoapp` stay untainted.

## 3. Validate MySQL scheduling rules

Check the `StatefulSet` spec:

```bash
kubectl get statefulset mysql -n mysql -o yaml
```

Confirm in the output:

- `tolerations` contains `key: app`, `value: mysql`, `effect: NoSchedule`
- `nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution` targets `app=mysql`
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` uses `topologyKey: kubernetes.io/hostname`

Check pod placement:

```bash
kubectl get pods -n mysql -o wide
```

Expected result:

- The two MySQL pods run only on nodes labeled `app=mysql`
- The two MySQL pods are placed on different nodes

## 4. Validate app scheduling rules

Check the `Deployment` spec:

```bash
kubectl get deployment todoapp -n todoapp -o yaml
```

Confirm in the output:

- `replicas: 2`
- `nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` targets `app=todoapp`
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` uses `topologyKey: kubernetes.io/hostname`

Check pod placement:

```bash
kubectl get pods -n todoapp -o wide
```

Expected result:

- The app pods prefer nodes labeled `app=todoapp`
- The app pods are placed on different nodes

## 5. Validate workload readiness

Run:

```bash
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A
```

Optional rollout checks:

```bash
kubectl rollout status statefulset/mysql -n mysql
kubectl rollout status deployment/todoapp -n todoapp
```

## 6. Validate the app endpoint

Check the NodePort service:

```bash
kubectl get svc -n todoapp
```

If the service is ready, open the app from your host:

```bash
curl http://localhost:30008
```

If ingress is enabled and ready:

```bash
kubectl get ingress -n todoapp
curl http://localhost/
```
