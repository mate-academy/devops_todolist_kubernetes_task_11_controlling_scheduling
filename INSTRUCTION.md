# How to validate the changes:
# Deploy the resources:
./bootstrap.sh
# How to check taints:
kubectl get nodes --show-labels
kubectl taint nodes <nodes name> app=mysql:NoSchedule
# How to check pods:
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide