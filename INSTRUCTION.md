kind create --config cluster.yml
kubectl create namespace mysql
kubectl create namespace todoapp
kubectl apply -f .infrastructure/mysql/statefulSet.yml
kubectl apply -f .infrastructure/app/deployment