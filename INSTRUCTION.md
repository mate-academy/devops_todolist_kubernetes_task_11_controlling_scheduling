# Validation Instructions
## 1. Start cluster
```bash
kind create cluster --config cluster.yml

./bootstrap.sh

kubectl get pods -A

kubectl get nodes -o json | jq '.items[].spec.taints'

kubectl get nodes --show-labels

kubectl get nodes -o wide
kubectl describe node <node-name> | grep Taints

kubectl get statefulset -A
kubectl get pods -l app=mysql -o wide

kubectl get deployment -A
kubectl get pods -l app=todoapp -o wide

kubectl get statefulset mysql -o yaml | grep -A 20 affinity
kubectl get deployment todoapp -o yaml | grep -A 20 affinity

kubectl get pods -o wide

