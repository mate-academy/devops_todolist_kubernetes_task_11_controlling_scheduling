## 1. Spin up a cluster

```bash
kind create cluster --config cluster.yml
```

## 2. Run the bootstrap script

```bash
./bootstrap.sh
```

## 3. Validate the changes
Check taints on MySQL nodes

Verify that the taints were correctly applied to the MySQL worker nodes from the cluster.yml configuration:
```bash
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```
Expected output: You should see your mysql worker nodes listing the app=mysql:NoSchedule taint.

Validate MySQL StatefulSet placement (Node Affinity & Pod Anti-Affinity)

Check which nodes the MySQL pods are running on:
```bash
kubectl get pods -n mysql -o wide
```
Expected output: 
1. Both pods must be running only on nodes with the app=mysql label (validation of node affinity).
2. The pods mysql-0 and mysql-1 must be on different nodes (validation of Pod Anti-Affinity).

Validate app deployment placement (node affinity & pod anti-affinity)

Check which nodes the application pods are running on:
```bash
kubectl get pods -n todoapp -o wide
```
Expected output:
1. The pods should preferentially land on nodes with the app=todoapp label.
2. No two replicas of the app should share the same node.
