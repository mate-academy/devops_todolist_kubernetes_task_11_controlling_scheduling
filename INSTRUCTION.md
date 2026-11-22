How to validate the changes

# Create the kind cluster
From the repository root, run:

kind create cluster --config cluster.yml

# Expected result:
Set kubectl context to "kind-kind"
You can now use your cluster with:
kubectl cluster-info --context kind-kind

# To get labels and taints you can use:

kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

# Expected result:
Yo'll se a list of nodes and their daints and labels to rught. app=mysql and app=todoapp labels must be there

Use taint command only for nodes with app=mysql label
# To tint your node you can use this command:

kubectl taint nodes <mysql-node-name> app=mysql:NoSchedule

# Expected result:
Nodes must have taints now
kind-worker         [map[effect:NoSchedule key:app value:mysql]]
kind-worker2         [map[effect:NoSchedule key:app value:mysql]]

# Deploy the application
Run:

./bootstrap.sh

# If deployment fails
Check the status of the resources:

kubectl get pods -A -o wide
kubectl get events -A --sort-by=.lastTimestamp

# For a failed application pod, inspect its description and logs:

kubectl describe pod -n todoapp <pod-name>
kubectl logs -n todoapp <pod-name> --previous

3. Додай перевірку розміщення Pod-ів
# To check pods location status and affinity requirements use this commands:

kubectl get pods -A -o wide
kubectl get nodes --show-labels

# Expected result:
MySQL runs in node with app=mysql label
Todo app runs in node with app=todoapp label
Apps replicas shouldn't be located in same node

# To check your deployment and stateful set use this commands:

kubectl get statefulset,deployments -A
kubectl rollout status statefulset/<name> -n <namespace>
kubectl rollout status deployment/<name> -n <namespace>

# To check your taints and tolerations use this commands:

kubectl describe node <mysql-node-name>
kubectl describe pod <mysql-pod-name> -n <namespace>

# Expected result:
app=mysql:NoSchedule
А MySQL Pod must be Running, бо його StatefulSet містить відповідний toleration.

# Logs commands
kubectl logs -n todoapp <pod-name> --previous
kubectl logs -n todoapp <pod-name>