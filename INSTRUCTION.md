# Verification Guide

### 1. **Checking labels and taints:**
   `kubectl get nodes --show-labels` (you should see `app=mysql`)
   `kubectl describe node <mysql_worker_name> | grep Taints` (should show `app=mysql:NoSchedule`)

### 2. **Checking MySQL placement:**
   `kubectl get pods -n mysql -o wide`
   Make sure the mysql pods are on nodes with the app=mysql label. Thanks to `podAntiAffinity`, they should be on **different** nodes.

### 3. **Checking todoapp placement:**
   `kubectl get pods -n todoapp -o wide`
   The pods should be on a node with the app=todoapp label.

### 4. **Stability check:**
   Try deleting the mysql pod: `kubectl delete pod <pod_name> -n mysql`. A new pod should automatically start up on the correct node thanks to `tolerations`.