In order to validate the taints and labels have been applied correctly:

kubectl get nodes --show-labels
kubectl describe node <node-name> | grep Taints

In order to validate that the pods are bound to a node:

kubectl get pods -n todoapp
kubectl describe pod <pod-name>

kubectl get pods -n mysql
kubectl describe pod <pod-name>

Test connectivity to the mysql pods with:

kubectl run -it mysql-client -n mysql --image=mysql:8.0 -- /bin/sh
mysql -h mysql-0.mysql -u root -p

Test connectivity to the todoapp pods with:

kubectl run -it niklafinskiy/alpine-curl:1.0.0 -n todoapp
curl -v http://<service-name>/api/ready