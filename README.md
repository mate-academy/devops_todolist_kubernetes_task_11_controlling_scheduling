# Apply cluster
kind create cluster --config=cluster.yml

# Apply all changes
bootstrap.sh

# Verify status
kubectl get pods -o wide

kubectl get nodes --show-labels
