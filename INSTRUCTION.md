kind create cluster --config cluster.yml

kubectl get nodes

kubectl get nodes -o json | jq '.items[] | {name: .metadata.name, taints: .spec.taints}'

kubectl get nodes -l app=mysql

kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule

chmod +x bootstrap.sh

./bootstrap.sh