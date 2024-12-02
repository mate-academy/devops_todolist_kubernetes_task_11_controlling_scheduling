# Pod and Node affinities for TodoApp

## 1. Start a cluster:
```bash
kind create cluster --config cluster.yml
```

## 2. Deploy Todoapp and all the additional resources:
```bash
bootstrap.sh
```

## 3. Check if the StatefulSet and Deployment have been correctly applied:

```bash 
kubectl get statefulset -n mysql
kubectl get deployment -n todoapp
```

## 4. Check the nodes and their labels:
```bash
kubectl get nodes --show-labels
```
Verify that the nodes have the correct labels, especially the ones with app=mysql for MySQL and app=todoapp for TodoApp.

## 5.  Check node affinity and pod anti-affinity for MySQL and TodoApp pods.
```bash
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide
```
- For MySQL pods: Ensure they are scheduled on nodes labeled with app=mysql.
- For TodoApp pods: Ensure they are scheduled on nodes labeled with app=todoapp.

Ensure that MySQL and TodoApp pods are not scheduled on the same node. Check the NODE column and verify that the value differs for MySQL and TodoApp pods.
If any pod is scheduled on a node with another pod of the same application, this indicates an issue with the pod anti-affinity rules.
