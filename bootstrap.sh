#!/bin/bash
set -e

CLUSTER_NAME="scheduling"

# 1. Create the kind cluster if it does not exist
echo "Checking Kubernetes cluster..."

if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  echo "Creating kind cluster..."
  kind create cluster --name "$CLUSTER_NAME" --config cluster.yml
else
  echo "Cluster already exists."
fi

# Select the correct Kubernetes context
kubectl config use-context "kind-$CLUSTER_NAME"

# Wait for all nodes
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# 2. Inspect node labels and taints
echo "Node labels before configuration:"
kubectl get nodes --show-labels

echo "Node taints before configuration:"
kubectl describe nodes | grep -E '^Name:|^Taints:'

# 3. Identify worker nodes
workers=($(kubectl get nodes \
  -l '!node-role.kubernetes.io/control-plane' \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | sort))

if [ "${#workers[@]}" -ne 4 ]; then
  echo "Error: Expected exactly 4 worker nodes."
  exit 1
fi

# 4. Configure three MySQL worker nodes
for node in "${workers[@]:0:3}"; do
  kubectl label node "$node" app=mysql --overwrite
  kubectl taint node "$node" app=mysql:NoSchedule --overwrite
done

# 5. Configure the Django worker node
kubectl label node "${workers[3]}" app=todoapp --overwrite

# 6. Verify labels and taints
echo "Node labels after configuration:"
kubectl get nodes -L app

echo "Node taints after configuration:"
kubectl describe nodes | grep -E '^Name:|^Taints:'

# 7. Deploy MySQL
kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl rollout status statefulset/mysql \
  -n mysql --timeout=300s

# 8. Deploy Django ToDo App
kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/deployment.yml

# 9. Wait for Django
kubectl rollout status deployment/todoapp \
  -n todoapp --timeout=300s

# 10. Final verification
echo "Final node configuration:"
kubectl get nodes -L app

echo "MySQL Pods:"
kubectl get pods -n mysql -o wide

echo "Django Pods:"
kubectl get pods -n todoapp -o wide

echo "Deployment completed."
