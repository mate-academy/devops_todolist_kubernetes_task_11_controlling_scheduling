Start: 
write command in terminal : ".\bootstrap.sh"

Validate the changes:
kubectl get nodes --show-labels 
kubectl get pods -n todoapp -o wide 
kubectl get pods -n mysql -o wide 