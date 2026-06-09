# Validation Instructions

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## 1. Create the cluster and deploy resources

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

The script will:

1. Create a `kind` cluster named `todoapp` from `cluster.yml`
2. Taint nodes labeled `app=mysql` with `app=mysql:NoSchedule`
3. Deploy MySQL and ToDo app resources
4. Install the Ingress controller and apply the Ingress manifest

## 2. Inspect node labels and taints

List all nodes with their labels:

```bash
kubectl get nodes --show-labels
```

Expected labels:

- 2 worker nodes with `app=mysql`
- 3 worker nodes with `app=todoapp`
- 1 control-plane node with `ingress-ready=true`

Check taints on MySQL nodes:

```bash
kubectl describe nodes -l app=mysql | grep -A2 Taints
```

Expected output for each MySQL node:

```
Taints:             app=mysql:NoSchedule
```

Verify that `app=todoapp` nodes have no `app=mysql` taint:

```bash
kubectl describe nodes -l app=todoapp | grep -A2 Taints
```

## 3. Validate MySQL StatefulSet scheduling

Check that both MySQL pods are running:

```bash
kubectl get pods -n mysql -o wide
```

Expected:

- 2 pods in `Running` state
- Each pod scheduled on a different node (`NODE` column must differ)
- Both pods scheduled only on nodes labeled `app=mysql`

Verify pod anti-affinity (pods on different nodes):

```bash
kubectl get pods -n mysql -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

Verify node affinity and tolerations in the StatefulSet:

```bash
kubectl get statefulset mysql -n mysql -o yaml | grep -A30 affinity
kubectl get statefulset mysql -n mysql -o yaml | grep -A6 tolerations
```

## 4. Validate ToDo app Deployment scheduling

Wait until HPA scales the deployment to at least 2 replicas:

```bash
kubectl get hpa -n todoapp
kubectl get pods -n todoapp -o wide
```

Expected:

- At least 2 `todoapp` pods in `Running` state
- Each pod scheduled on a different node (`NODE` column must differ)
- Pods prefer nodes labeled `app=todoapp`

Verify pod anti-affinity (pods on different nodes):

```bash
kubectl get pods -n todoapp -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName
```

Verify node affinity and pod anti-affinity in the Deployment:

```bash
kubectl get deployment todoapp -n todoapp -o yaml | grep -A30 affinity
```

Expected affinity rules:

- `preferredDuringSchedulingIgnoredDuringExecution` for `app=todoapp` nodes
- `requiredDuringSchedulingIgnoredDuringExecution` pod anti-affinity on `kubernetes.io/hostname`

## 5. Verify application health

Check pod readiness:

```bash
kubectl get pods -n mysql
kubectl get pods -n todoapp
```

All pods should be `Running` and `READY` (e.g. `1/1`).

Test the application via NodePort:

```bash
kubectl get svc -n todoapp
```

Open `http://localhost:30007` in a browser or run:

```bash
curl http://localhost:30007/api/health
```

Expected: HTTP 200 response.

## 6. Cleanup

```bash
kind delete cluster --name todoapp
```
