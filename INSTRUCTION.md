# How to validate scheduling, affinity, and taints in the cluster

## Prerequisites

Run the [`bootstrap.sh`](./bootstrap.sh) script to setup a new cluster and deploy components:

```sh
bash bootstrap.sh
```

1. Check node labels and taints
   ```sh
   kubectl get nodes --show-labels
   kubectl describe nodes | grep -A 5 Taints
   ```
   - make sure nodes have the correct `app=mysql` and `app=todoapp` labels
   - make sure nodes with `app=mysql` are tainted with `app=mysql:NoSchedule`

2. Check `mysql` pods are scheduled on correct nodes
   ```sh
   kubectl get pods -n mysql -o wide
   ```
   - verify each mysql pod is running on a node with the `app=mysql` label
   - verify mysql pods are not scheduled on the same node (pod anti-affinity)
   - verify pods are running (STATUS should be Running)

3. Check `todoapp` pods are scheduled on correct nodes
   ```sh
   kubectl get pods -n todoapp -o wide
   ```
   - verify each todoapp pod is running on a node with the `app=todoapp` label (preferred)
   - verify todoapp pods are not scheduled on the same node (pod anti-affinity)
   - verify pods are running (STATUS should be Running)

4. Check pod tolerations and affinity rules
   ```sh
   kubectl get pod -n mysql -o yaml | grep -A 20 tolerations
   kubectl get pod -n mysql -o yaml | grep -A 20 affinity
   kubectl get pod -n todoapp -o yaml | grep -A 20 affinity
   ```
   - confirm tolerations for `app=mysql` on mysql pods
   - confirm nodeAffinity and podAntiAffinity rules are present on both mysql and todoapp pods

5. Optional: describe a pod for detailed scheduling info
   ```sh
   kubectl describe pod <pod-name> -n <namespace>
   ```
   - look for messages about affinity, taints, and tolerations in the Events section
