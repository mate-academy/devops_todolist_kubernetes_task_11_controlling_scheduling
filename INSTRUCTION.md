# Kubernetes: Scheduling Control for TodoApp & MySQL

1. Підготовка кластеру (kind)


kind create cluster --config cluster.yml
Впевніться, що ноди мають мітки і taints:

kubectl label node <mysql-node> app=mysql
kubectl label node <todo-node> app=todoapp
kubectl taint node <mysql-node> app=mysql=NoSchedule:NoSchedule

2. Розгортання ресурсів

chmod +x bootstrap.sh
./bootstrap.sh

3. Перевірка розміщення подів

Для MySQL:

kubectl get pods -l app=mysql -o wide
➡ Переконайтесь, що кожен pod заплановано на різних вузлах, які мічені app=mysql, і що ніхто не запланований на вузлі без такого лейблу.

Для TodoApp:

kubectl get pods -l app=todoapp -o wide
Pods мають бути запущені на різних вузлах, впорядковані на вузлах із міткою app=todoapp.

4. Перевірка affinity та anti-affinity

Pods MySQL не повинні ділити вузол між собою.
Pods TodoApp намагаються уникнути розміщення один разом, але допускають за необхідності, і тільки на вузлах із app=todoapp.

5. Оновлення конфігурації

kubectl delete statefulset/mysql
kubectl delete deployment/todoapp
Після цього — ./bootstrap.sh