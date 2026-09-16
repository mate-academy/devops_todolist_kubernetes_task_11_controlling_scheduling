# Manage Scheduling: Taint, Tolerations and Affinity

## Prerequisites
* `kind` cluster running
* Namespace `todoapp` and `mysql`

## Deploy

```bash
chmod +x bootstrap.sh
```

### Step 1: Verify Cluster Nodes, Labels, and Taints:

```bash
# Add taint as `app=mysql:NoSchedule` for nodes with label as `app=mysql`
kubectl taint nodes <worker-node-name> app=mysql:NoSchedule

# Inspect nodes for Taints
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Inspect nodes for Labels
kubectl get nodes --show-labels

# Expected: 2 nodes with taint `app=mysql:NoSchedule`
```

### Step 2. Validate MySQL StatefulSet Scheduling:

```bash
# Check that MySQL pods are scheduled on mysql-labeled nodes
kubectl get pods -n mysql -o wide

# Verify each MySQL pod is on a node with app=mysql label
kubectl get pods -n mysql -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' | while read pod node; do
  label=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.app}')
  echo "$pod → $node (app=$label)"
done

# Expected: both MySQL pods on nodes labeled app=mysql
```

### Step 3. Validate MySQL Pod Anti-Affinity:

```bash
# Check that MySQL pods are on different nodes
kubectl get pods -n mysql -o jsonpath='{.items[*].spec.nodeName}' | tr ' ' '\n' | sort | uniq -c

# Expected: each node appears at most once (no two MySQL pods on the same node)
```

### Step 4. Validate TodoApp Deployment Scheduling:

```bash
# Check that todoapp pods are scheduled on todoapp-labeled nodes
kubectl get pods -n todoapp -o wide

# Verify each pod is on a node with app=todoapp label
kubectl get pods -n todoapp -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}' | while read pod node; do
  label=$(kubectl get node "$node" -o jsonpath='{.metadata.labels.app}')
  echo "$pod → $node (app=$label)"
done

# Expected: all todoapp pods on nodes labeled app=todoapp
```

### Step 5. Validate TodoApp Pod Anti-Affinity:

```bash
# Check that todoapp pods are on different nodes
kubectl get pods -n todoapp -o jsonpath='{.items[*].spec.nodeName}' | tr ' ' '\n' | sort | uniq -c

# Expected: each node appears at most once (no two todoapp pods on the same node)
```

### Step 6. Verify Affinity Rules Applied Correctly:

```bash
# Inspect the pod spec for scheduling constraints
kubectl get pod -n mysql -l app=mysql -o jsonpath='{range .items[0]}{.spec.affinity}{"\n"}{end}'
kubectl get pod -n todoapp -l app=todoapp -o jsonpath='{range .items[0]}{.spec.affinity}{"\n"}{end}'

# Verify tolerations on MySQL pods
kubectl get pod -n mysql -l app=mysql -o jsonpath='{range .items[0]}{.spec.tolerations}{"\n"}{end}'
```

### Step 7. Check Pod Status:

```bash
# All pods should be Running
kubectl get pods -n mysql
kubectl get pods -n todoapp

# Expected: all pods in Running state
```

### Step 8. Test Application Access:

```bash
# Get the NodePort for the todoapp service
kubectl get svc -n todoapp

# Access the application via the NodePort
curl http://<node-ip>:<nodeport>/
```

### Step 9. Verify node labels are correct:

```bash
kubectl get nodes --show-labels | grep -E "app=mysql|app=todoapp"
```