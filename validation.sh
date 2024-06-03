#!/bin/bash

check_status() {
  if [ $? -eq 0 ]; then
    echo -e "✅  $1"
  else
    echo -e "❌  $1"
  fi
}

check_taints() {
  node=$1
  taints=$(kubectl describe node "$node" | grep -A 5 Taints)
  if [[ "$taints" == *"<none>"* ]]; then
    echo -e "✅  $node: No Taints"
  else
    echo -e "❌  $node: Taints Found"
    echo "$taints"
  fi
}

# Check for namespaces
echo "Checking for namespaces..."
kubectl get namespaces >/dev/null 2>&1
check_status "Namespaces check"

# Validate MySQL configuration
echo "Validating MySQL configuration..."
kubectl get configmap -n mysql >/dev/null 2>&1
check_status "MySQL ConfigMap"
kubectl get secret -n mysql >/dev/null 2>&1
check_status "MySQL Secret"
kubectl get svc -n mysql >/dev/null 2>&1
check_status "MySQL Service"
kubectl get statefulset -n mysql >/dev/null 2>&1
check_status "MySQL StatefulSet"

# Validate ToDo App configuration
echo "Validating ToDo App configuration..."
kubectl get pv >/dev/null 2>&1
check_status "PersistentVolume"
kubectl get pvc -n todoapp >/dev/null 2>&1
check_status "PersistentVolumeClaim"
kubectl get configmap -n todoapp >/dev/null 2>&1
check_status "ToDo App ConfigMap"
kubectl get secret -n todoapp >/dev/null 2>&1
check_status "ToDo App Secret"
kubectl get svc -n todoapp >/dev/null 2>&1
check_status "ToDo App Service"
kubectl get deployment -n todoapp >/dev/null 2>&1
check_status "ToDo App Deployment"
kubectl get hpa -n todoapp >/dev/null 2>&1
check_status "ToDo App HPA"

# Validate Ingress Controller
echo "Validating Ingress Controller..."
kubectl get pods -n ingress-nginx >/dev/null 2>&1
check_status "Ingress Controller"

# Check MySQL Pods deployment
echo "Checking MySQL Pods deployment..."
kubectl get pods -n mysql -l app=mysql >/dev/null 2>&1
check_status "MySQL Pods"

# Check ToDo App Pods deployment
echo "Checking ToDo App Pods deployment..."
kubectl get pods -n todoapp -l app=todoapp >/dev/null 2>&1
check_status "ToDo App Pods"

# Validate Affinity and Anti-Affinity rules for MySQL
echo "Validating Affinity and Anti-Affinity rules for MySQL..."
kubectl describe statefulset mysql -n mysql | grep -A 10 Affinity | tee mysql_affinity_check.txt
check_status "MySQL Affinity and Anti-Affinity"

# Validate Affinity and Anti-Affinity rules for ToDo App
echo "Validating Affinity and Anti-Affinity rules for ToDo App..."
kubectl describe deployment todoapp -n todoapp | grep -A 10 Affinity | tee todoapp_affinity_check.txt
check_status "ToDo App Affinity and Anti-Affinity"

# Check node taints
echo "Checking node taints..."
nodes=$(kubectl get nodes -o jsonpath='{.items[*].metadata.name}')

for node in $nodes; do
  check_taints "$node"
done

# Check node labels
echo "Checking node labels..."
kubectl get nodes --show-labels >/dev/null 2>&1
check_status "Node Labels"

echo "All checks completed."
