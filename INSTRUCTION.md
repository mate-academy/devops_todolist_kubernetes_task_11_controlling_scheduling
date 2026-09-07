## Deploy the cluster

Run the cluster creation command:

```bash
kind create cluster --config cluster.yml  
```

Run the bootstrap script:

```bash
bash bootstrap.sh
```

## Validate labels and taints

Confirm that two workers are labeled for MySQL and three workers are labeled for the application:

```bash
kubectl get nodes --show-labels
kubectl get nodes -l app=mysql
kubectl get nodes -l app=todoapp
```

Confirm that every MySQL node has the required taint:

```bash
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Each selected node must show `app=mysql:NoSchedule`.

## Validate scheduling rules

Check that all MySQL replicas are running and that they are on different nodes:

```bash
kubectl -n mysql get pods -o wide
kubectl -n mysql rollout status statefulset/mysql --timeout=180s
```

The MySQL pods must run on nodes labeled `app=mysql`, must tolerate the `app=mysql:NoSchedule` taint, and must not share a node because of the required pod anti-affinity rule.

Check the ToDo application deployment:

```bash
kubectl -n todoapp get pods -o wide
kubectl -n todoapp rollout status deployment/todoapp --timeout=180s
```

Application pods should prefer nodes labeled `app=todoapp`. No two application pods may share a node while enough labeled nodes are available because the deployment uses required pod anti-affinity.

Inspect the effective scheduling rules when needed:

```bash
kubectl -n mysql get statefulset mysql -o yaml
kubectl -n todoapp get deployment todoapp -o yaml
```

Verify that the StatefulSet contains a MySQL toleration, required MySQL node affinity, and required MySQL pod anti-affinity. Verify that the Deployment contains preferred `app=todoapp` node affinity and required ToDo pod anti-affinity.

## Validate services and ingress

```bash
kubectl -n mysql get svc
kubectl -n todoapp get svc
kubectl -n ingress-nginx get pods
kubectl -n todoapp get ingress
```

All expected pods should be `Running` or `Completed`, the rollout commands should succeed, and the Ingress resource should exist after the ingress controller is ready. The application health endpoints are available through the service at `/api/health` and `/api/ready`.

## Cleanup

Delete the kind cluster after validation:

```bash
kind delete cluster
```
