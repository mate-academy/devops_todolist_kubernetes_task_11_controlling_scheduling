# Pod and Node Affinities for TodoApp

## 1. Start the Cluster

Create a Kubernetes cluster using `kind` with the specified configuration:

```bash
kind create cluster --config cluster.yml
```

## 2. Deploy TodoApp and Additional Resources

Run the bootstrap script to deploy the TodoApp and necessary resources:

```bash
./bootstrap.sh
```

## 3. Verify StatefulSet and Deployment

Check that the StatefulSet and Deployment have been applied successfully:

```bash
kubectl get statefulset -n mysql
kubectl get deployment -n todoapp
```

## 4. Inspect Nodes and Labels

List all nodes with their labels to ensure they have the correct labeling:

```bash
kubectl get nodes --show-labels
```

**Verify** that nodes have the following labels:
- Nodes for MySQL should be labeled: `app=mysql`
- Nodes for TodoApp should be labeled: `app=todoapp`

## 5. Check Node Affinity and Pod Anti-Affinity

Verify that the pods are scheduled on the appropriate nodes:

```bash
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
```

### For MySQL Pods
- Ensure they are scheduled on nodes labeled `app=mysql`.

### For TodoApp Pods
- Ensure they are scheduled on nodes labeled `app=todoapp`.

