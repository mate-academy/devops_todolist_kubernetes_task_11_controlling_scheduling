Clone repository
clone repository
git clone https://github.com/Foxytail8/devops_todolist_kubernetes_task_11_controlling_scheduling.git
go to folder repository
cd ./devops_todolist_kubernetes_task_11_controlling_scheduling

## PREDEPLOY
if you have cluster - delete it
kind delete cluster

create cluster
kind create cluster --config cluster.yml

## DEPLOY
start file bootstrap
sh ./bootstrap.sh

## TESTING
kubectl get pods -n todoapp -o wide
kubectl get pods -n mysql -o wide
kubectl get nodes --show-labels
kubectl describe node worker
kubectl describe node worker2
