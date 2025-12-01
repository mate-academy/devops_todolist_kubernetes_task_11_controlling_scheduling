# How to validate

1. Create cluster and deploy resources:

   ```bash
   ./bootstrap.sh

# Check nodes, labels and taints:
kubectl get nodes --show-labels
kubectl describe nodes | grep -A3 "Taints"

# Check MySQL and todoapp pods:
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide

# Open application (NodePort/Ingress) and verify it works