#!/bin/bash

set -e


kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/mysql/ns.yml


kubectl label node todoapp-worker app=mysql --overwrite
kubectl label node todoapp-worker2 app=mysql --overwrite
kubectl label node todoapp-worker3 app=mysql --overwrite
kubectl label node todoapp-worker4 app=todoapp --overwrite


kubectl taint node todoapp-worker app=mysql:NoSchedule --overwrite
kubectl taint node todoapp-worker2 app=mysql:NoSchedule --overwrite
kubectl taint node todoapp-worker3 app=mysql:NoSchedule --overwrite


kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml


kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/deployment.yml


kubectl get nodes --show-labels


kubectl get pods -n mysql -o wide


kubectl get pods -n todoapp -o wide