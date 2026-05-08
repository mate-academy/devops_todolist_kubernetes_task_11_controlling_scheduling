### 1. Run bootstrap.sh for deploy todoapp and mysql db
### 2. To validate correct scheduling pods to nodes:
1. Check nodes taints:
   ```
   kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
   ```
2. To check correct scheduling mysql pods:
   ```
    kubectl get pods -n mysql -o wide
   ```
   and inspect that pods don't run on the same node and running on node with "app=mysql" label
3. To check correct schduling todoapp pods:
   ```
    kubectl get pods -n todoapp -o wide
   ```
   and inspect that pods don't run on the same node and running on node with "app=todoapp" label
    