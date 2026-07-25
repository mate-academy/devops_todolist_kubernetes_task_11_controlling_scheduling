# ToDo App — Node Affinity & Taints Instructions

## Prerequisites

- `kind` installed (https://kind.sigs.k8s.io/)
- `kubectl` installed and configured
- Docker running locally

## 1. Create the cluster

Spin up a local Kubernetes cluster using `kind` and the provided
configuration file:

```bash
kind create cluster --config cluster.yml
```

Verify the cluster is up:

```bash
kubectl cluster-info --context kind-kind
```

## 2. Inspect node labels and taints

Before deploying anything, inspect the nodes to confirm the expected
labels are present:

```bash
kubectl get nodes --show-labels
```

You should see nodes labeled `app=mysql` and `app=todoapp`.

Check the taints currently applied to the nodes (should be empty at
this point, before running `bootstrap.sh`):

```bash
kubectl describe nodes | grep -A 3 Taints
```

## 3. Deploy all resources

Run the bootstrap script, which taints the `app=mysql` node and deploys
all required resources:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 4. Validate the taint was applied

```bash
kubectl describe nodes | grep -A 3 Taints
```

The node labeled `app=mysql` should now show the taint
`app=mysql:NoSchedule`.

## 5. Validate the MySQL StatefulSet scheduling

Check that the MySQL pod(s) are running and scheduled on the tainted,
`app=mysql`-labeled node:

```bash
kubectl get pods -n mysql -o wide
```

Confirm the `NODE` column shows the `app=mysql` labeled node — this
validates that:
- The pod tolerates the `app=mysql:NoSchedule` taint (toleration works)
- Node Affinity correctly steered the pod to the `app=mysql` node

If there are multiple MySQL replicas, confirm they are **not** scheduled
on the same node (Pod Anti-Affinity):

```bash
kubectl get pods -n mysql -o wide
```

Each MySQL pod should show a different value in the `NODE` column.

## 6. Validate the app Deployment scheduling

Check that the app pods are running and preferentially scheduled on the
`app=todoapp`-labeled node:

```bash
kubectl get pods -n todoapp -o wide
```

Confirm the `NODE` column shows the `app=todoapp` labeled node (this is
a **preferred**, not required, rule — so it may occasionally schedule
elsewhere if that node is unavailable, but under normal conditions it
should land there).

If there are multiple app replicas, confirm Pod Anti-Affinity is
spreading them across different nodes:

```bash
kubectl get pods -n todoapp -o wide
```

## 7. Validate scheduling events (optional deep-dive)

To confirm *why* the scheduler placed a pod where it did, describe the
pod and check the `Events` section:

```bash
kubectl describe pod <pod-name> -n mysql
kubectl describe pod <pod-name> -n todoapp
```

(Replace `<pod-name>` with an actual pod name from `kubectl get pods -n <namespace>`.)

## 8. Validate the app is accessible

```bash
kubectl port-forward -n todoapp service/todoapp-service 8000:80
```

Open http://localhost:8000 in your browser and confirm the app loads
correctly.

## Cleaning up

```bash
kind delete cluster
```