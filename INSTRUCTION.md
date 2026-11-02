# Validation Instructions

## 1. Create the Kubernetes cluster

```kind create cluster --config cluster.yml```

## 2. Verify the cluster nodes

```kubectl get nodes```

All nodes should be in the Ready state.

## 3. Deploy all required resources

```bash bootstrap.sh```

Wait until all required pods are running.

## 4. Verify Node labels and taints

```kubectl get nodes --show-labels```

Verify that:
- kind-worker and kind-worker2 have the app=mysql label.
- kind-worker3, kind-worker4, and kind-worker5 have the app=todoapp label.

Check the MySQL nodes in detail:

```kubectl describe node kind-worker```
```kubectl describe node kind-worker2```

Verify that both MySQL nodes have the following taint:

app=mysql:NoSchedule

## 5. Verify MySQL pod scheduling

```kubectl get pods -n mysql -o wide```

Verify that:
- MySQL pods are running on nodes labeled app=mysql.
- MySQL pods are scheduled on different nodes.

Inspect the MySQL pods if needed:

```kubectl get nodes -l app=mysql```

## 6. Verify Todo application pod scheduling

```kubectl get pods -n todoapp -o wide```

Verify that:
- Todo application pods prefer nodes labeled app=todoapp.
- Todo application pods are scheduled on different nodes.

To inspect a Todo application pod in detail, copy its name from the previous command and run:

```kubectl describe pod <todoapp-pod-name> -n todoapp```

## 7. Verify all pods in the cluster

```kubectl get pods -A -o wide```

Verify that the required application and MySQL pods are running and distributed across the expected nodes.