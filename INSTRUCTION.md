# Kubernetes Node Affinity, Pod Anti-Affinity, Taints and Tolerations

## 1. Create the Kind cluster

Create the cluster using the provided `cluster.yml`:

```bash
kind create cluster --name todoapp --config cluster.yml
```

Check the cluster nodes:

```bash
kubectl get nodes
```

All nodes must have the `Ready` status.

## 2. Inspect node labels and taints

Display node labels:

```bash
kubectl get nodes --show-labels
```

Display node taints:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Detailed node information can be checked with:

```bash
kubectl describe nodes
```

## 3. Run bootstrap

Make the script executable:

```bash
chmod +x bootstrap.sh
```

Run it:

```bash
./bootstrap.sh
```

The script creates the required namespaces, labels the nodes, adds MySQL taints, and deploys the required resources.

## 4. Validate node labels

Run:

```bash
kubectl get nodes --show-labels
```

Expected configuration:

* `todoapp-worker` has `app=mysql`
* `todoapp-worker2` has `app=mysql`
* `todoapp-worker3` has `app=mysql`
* `todoapp-worker4` has `app=todoapp`

## 5. Validate MySQL node taints

Run:

```bash
kubectl describe node todoapp-worker
kubectl describe node todoapp-worker2
kubectl describe node todoapp-worker3
```

Each MySQL node must contain:

```text
app=mysql:NoSchedule
```

## 6. Validate MySQL StatefulSet

Check the StatefulSet:

```bash
kubectl get statefulset mysql -n mysql
```

Check MySQL Pods:

```bash
kubectl get pods -n mysql -o wide
```

There must be three MySQL Pods:

```text
mysql-0
mysql-1
mysql-2
```

Each MySQL Pod must be scheduled on a different `app=mysql` node.

Check the StatefulSet configuration:

```bash
kubectl get statefulset mysql -n mysql -o yaml
```

Verify that it contains:

* a MySQL toleration for `app=mysql:NoSchedule`;
* required node affinity for `app=mysql`;
* required pod anti-affinity for MySQL Pods;
* `topologyKey: kubernetes.io/hostname`.

## 7. Validate TodoApp Deployment

Check the Deployment:

```bash
kubectl get deployment todoapp -n todoapp
```

Check its Pods:

```bash
kubectl get pods -n todoapp -o wide
```

Check the Deployment configuration:

```bash
kubectl get deployment todoapp -n todoapp -o yaml
```

Verify that the Deployment contains:

* `preferredDuringSchedulingIgnoredDuringExecution`;
* preferred node affinity for `app=todoapp`;
* required pod anti-affinity for `app=todoapp`;
* `topologyKey: kubernetes.io/hostname`.

The `app=todoapp` node should be preferred for TodoApp Pods.

## 8. Validate PVCs

Check MySQL persistent volume claims:

```bash
kubectl get pvc -n mysql
```

All required PVCs should be created successfully.

## 9. Final validation

Run:

```bash
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
kubectl get pvc -n mysql
```

The final state must satisfy:

* three worker nodes are labeled `app=mysql`;
* MySQL nodes have `app=mysql:NoSchedule`;
* MySQL tolerates the taint;
* MySQL uses required node affinity for `app=mysql`;
* MySQL Pods are distributed across different nodes using pod anti-affinity;
* one worker node is labeled `app=todoapp`;
* TodoApp prefers the `app=todoapp` node;
* TodoApp Pods use pod anti-affinity and are not placed on the same node as each other.
