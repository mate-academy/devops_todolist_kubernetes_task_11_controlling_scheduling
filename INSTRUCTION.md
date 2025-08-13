1.	Створити кластер Kind за допомогою конфігураційного файлу cluster.yml командою:

bash bootstrap.sh
	2.	Перевірити, що кластер запущений та ноди доступні:

kubectl get nodes -o wide
	3.	Перевірити, що ноди з лейблом app=mysql та taint app=mysql:NoSchedule присутні:

kubectl get nodes –-show-labels
kubectl describe node <ім’я_ноди> | grep -A2 Taints
	4.	Застосувати StatefulSet та переконатися, що MySQL поди запущені на нодах з потрібним taint та nodeAffinity:

kubectl get pods -n mysql -o wide
	5.	Перевірити Pod Anti-Affinity у MySQL, щоб поди не запускалися на одній ноді:

kubectl describe pod <ім’я_pod> -n mysql | grep -A5 Affinity
	6.	Застосувати Deployment для todoapp:

kubectl get pods -n todoapp -o wide
	7.	Перевірити, що Node Affinity та Pod Anti-Affinity у Deployment працюють, і поди розподілені по різних нодах з лейблом app=todoapp:

kubectl describe pod <ім’я_pod> -n todoapp | grep -A5 Affinity
	8.	Перевірити всі ресурси у кластерах:

kubectl get all –-all-namespaces
	9.	Для додаткової перевірки логів контейнерів:

kubectl logs <ім’я_pod> -n 
	10.	Переконатися, що всі поди Ready та працюють стабільно:

kubectl get pods –-all-namespaces