# Validation Instructions (Task 11: Controlling Scheduling)

## 1. Deploy Environment
Run the bootstrap script. This will recreate the cluster, apply taints to specific nodes, and deploy the application with the new scheduling rules.

```bash
sh bootstrap.sh
```
## 2. Validate Node Taints

We need to confirm that nodes labeled with app=mysql are correctly "tainted". This prevents standard pods (like our web app) from being scheduled on them.

Command:

```bash
kubectl describe nodes -l app=mysql | grep Taints
```

Expected Output: You should see:
```bash
Taints:             app=mysql:NoSchedule
```

## 3. Validate MySQL Scheduling (StatefulSet)

MySQL pods have Tolerations (to bypass the taint) and Node Affinity (to target specific nodes).

Command:
```bash
kubectl get pods -n mysql -o wide
```
Validation Checklist:

1. Status: All pods are Running.
2. Node Assignment: Look at the NODE column. The pods must be assigned to the nodes that have the app=mysql label (e.g., kind-worker, kind-worker2). 
3. Anti-Affinity: Each pod must be on a different node. Two MySQL pods should never share the same node name.

## 4. Validate TodoApp Scheduling (Deployment)
The TodoApp has Node Affinity (Preferred) to target app=todoapp nodes and Pod Anti-Affinity to spread replicas. It does not have tolerations for the MySQL nodes, so it must avoid them.

Command:
```bash
kubectl get pods -n todoapp -o wide
```
Validation Checklist:

1. Node Assignment: Look at the NODE column. The pods should be running on nodes labeled app=todoapp (e.g., kind-worker3, kind-worker4, etc.).
2. Avoidance: Ensure NO TodoApp pod is running on the MySQL nodes (the ones you identified in step 3).
3. Anti-Affinity: The pods should be distributed across different nodes (not stacking on a single worker).

## 5. Validate Application Access
Finally, ensure that despite the complex scheduling rules, the networking via Ingress still functions correctly.

Command:
```bash
curl -I http://localhost/
```
Expected Output:
```bash
HTTP/1.1 200 OK
...
```