1 install Python 3.8 and higher, due to Django 4
2 install kind
3 install kubectl

4 kind create cluster --config cluster.yml
5 run ./bootstrap.sh
6 kubectl apply -f .infrastructure/ingress/ingress.yml

7 kubectl label node kind-worker app=mysql
8 kubectl label node kind-worker2 app=mysql
9 kubectl taint nodes -l app=mysql app=mysql:NoSchedule

10 kubectl label node kind-worker app=todoapp
11 kubectl apply -f .infrastructure/app/deployment.yml

12 kubectl get nodes -n mysql -o wide
13 kubectl get pods -n mysql -o wide
14 kubectl get nodes -n todoapp -o wide
15 kubectl get pods -n todoapp -o wide

Expected results:
mysql pods only on app=mysql nodes, each on separate nodes
todoapp pods preferring app=todoapp nodes and not co-locating