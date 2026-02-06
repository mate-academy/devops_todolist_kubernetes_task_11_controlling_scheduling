# ToDo App with Advanced Scheduling

This setup demonstrates Node Affinity, Pod Anti-Affinity, and Taints/Tolerations.

# Deployment

### 1. **Recreate Cluster:**
   We need 3 worker nodes to demonstrate affinity rules properly.
   ```
   kind delete cluster
   kind create cluster --config cluster.yml
   ```
Run Bootstrap: This script will label nodes (app=mysql, app=todoapp) and taint MySQL nodes.

```
chmod +x bootstrap.sh
./bootstrap.sh
```
# Validation
### 1. Inspect Nodes Verify that nodes have correct labels and taints.

```
kubectl get nodes --show-labels
kubectl describe nodes | grep Taints
```
Expected: 2 nodes tainted with app=mysql:NoSchedule, 1 node labeled app=todoapp.

### 2. Verify MySQL Placement MySQL pods should only be running on the tainted nodes (due to Toleration + Node Affinity) and ideally spread out (Anti-Affinity).

```
kubectl get pods -n mysql -o wide
```
Observation: You might see one pod in Pending state if you only have 2 MySQL nodes but 3 replicas with strict Anti-Affinity. This is expected behavior proving the rules work!

### 3. Verify App Placement TodoApp pods should prefer the app=todoapp node but are not strictly forced. They must not run on the same node as each other.

```
kubectl get pods -n mateapp -o wide
```