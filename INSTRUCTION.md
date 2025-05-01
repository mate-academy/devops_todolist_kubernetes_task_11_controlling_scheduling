## Інструкція по перевірці:

1. Запустити кластер:
```bash
kind create cluster --config cluster.yml

chmod +x bootstrap.sh
./bootstrap.sh

kubectl get pods -o wide -n todoapp

kubectl describe pod <mysql-pod> -n todoapp

kubectl get pods -o json | jq '.items[].spec.affinity'
