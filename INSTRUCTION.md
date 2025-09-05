Create the kind cluster from the provided config:
kind create cluster --name todoapp --config cluster.yml
Bootstrap the cluster (installs NGINX ingress controller and deploys the app):
chmod +x bootstrap.sh && ./bootstrap.sh
Apply the Ingress manifest (if not already applied by bootstrap):
kubectl apply -f ./.infrastructure/ingress/ingress.yml

To verify nodes are labeled app=mysql and tainted app=mysql:NoSchedule:
  kubectl get nodes --show-labels
  kubectl describe node <mysql-node> | grep -i taints
  MySQL nodes have label app=mysql and taint app=mysql:NoSchedule.

To verify MySQL pods schedule only on those nodes and tolerate the taint:
  kubectl get pods -n <ns> -l app=mysql -o wide (node column should list only nodes with app=mysql).
  kubectl describe pod <mysql-pod> -n <ns> | grep -A5 Tolerations and ... | grep -A12 Affinity
  Toleration key=app, operator=Equal, value=mysql, effect=NoSchedule; 
  NodeAffinity requires app In [mysql].

To verify nodes labeled app=todoapp:
  kubectl get nodes --show-labels | grep app=todoapp

Confirm Deployment affinity/anti-affinity in pod spec:
  kubectl describe pod <todo-pod> -n <ns> | grep -A20 Affinity
  NodeAffinity preferred for app In [todoapp]; 
  PodAntiAffinity required with topologyKey=kubernetes.io/hostname against label app=todoapp.

To validate scheduling, pods spread across different nodes and preferably on app=todoapp nodes:
kubectl get pods -l app=todoapp -o wide 

Availability check:
kubectl get svc todoapp-service -o wide
http://localhost:30007/