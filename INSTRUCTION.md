chmod +x bootstrap.sh
kubectl create namespace mysql
kubectl create namespace todoapp

./bootstrap.sh

 <!-- Перевірити що все працює -->
kubectl get nodes -L app
kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide