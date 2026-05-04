# Validation Instructions
## Prerequisites
- Docker installed
- kind installed
- kubectl installed


## Steps to Validate
### 1. Create Cluster
```bash
kind create cluster --name todo-cluster --config cluster.yml
2. Verify Nodes
kubectl get nodes
kubectl describe nodes
3. Label Worker Node
WORKER_NODE=$(kubectl get nodes -o jsonpath='{.items[1].metadata.name}')
kubectl label nodes $WORKER_NODE app=mysql --overwrite
kubectl label nodes $WORKER_NODE app=todoapp --overwrite
4. Taint Node for MySQL
kubectl taint nodes $WORKER_NODE app=mysql:NoSchedule
5. Run Bootstrap Script
chmod +x bootstrap.sh
./bootstrap.sh
6. Verify StatefulSet
kubectl get statefulset -n mysql
kubectl get pods -n mysql -o wide
Check that:

MySQL pods are on different nodes (podAntiAffinity)
MySQL pods are on nodes with app=mysql label (nodeAffinity)
MySQL pods can be scheduled on tainted nodes (tolerations)

7. Verify Deployment
kubectl get deployment -n todoapp
kubectl get pods -n todoapp -o wide
Check that:

todoapp pods are on different nodes (podAntiAffinity)
todoapp pods prefer nodes with app=todoapp label (nodeAffinity)

8. Verify Resources
kubectl get all -n mysql
kubectl get all -n todoapp
kubectl get pvc -n todoapp
kubectl get secrets -n todoapp
kubectl get configmap -n todoapp
9. Cleanup
kind delete cluster --name todo-cluster