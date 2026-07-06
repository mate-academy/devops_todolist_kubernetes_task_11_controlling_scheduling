# Validation Instructions

## 1. Check for labels and Taints on nodes
kubectl get nodes --show-labels
kubectl describe nodes | grep -A5 "Taints"

## 2. Check for MySQL pods on nodes with label app=mysql
kubectl get pods -l app=mysql -n mysql -o wide
#namespace: mysql (not todoapp!)

## 3. Check for MySQL Anti-Affinity — each pod on a separate node
kubectl get pods -l app=mysql -n mysql -o wide | awk '{print $1, $7}'
# namespace: mysql

## 4. Check that todoapp Pod is running
kubectl get pod todoapp -n todoapp -o wide

## 5. Check that todoapp Deployment pods are running
kubectl get pods -l app=todoapp -n todoapp -o wide

## 6. Check Anti-Affinity todoapp — pods on different nodes
kubectl get pods -l app=todoapp -n todoapp -o wide | awk '{print $1, $7}'

## 7. Detailed check of affinity rules
kubectl describe pod todoapp -n todoapp | grep -A20 "Affinity"
kubectl describe pod mysql-0 -n mysql | grep -A20 "Affinity"

## 8. Check scheduler events
kubectl describe pod todoapp -n todoapp | grep -A10 "Events"
kubectl describe pod mysql-0 -n mysql | grep -A10 "Events"