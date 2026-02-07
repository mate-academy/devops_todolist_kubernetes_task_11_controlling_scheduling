Створіть кластер за допомогою kind та файлу cluster.yml. Після виконання bootstrap.sh переконайтесь, що кластер успішно створений, виконавши команду kubectl get nodes. Далі перевірте, що ноди мають коректні labels і taints, використовуючи kubectl describe nodes. Ноди для MySQL повинні мати лейбл app=mysql та taint app=mysql:NoSchedule, а ноди для застосунку — лейбл app=todoapp.

Перевірте StatefulSet MySQL, виконавши kubectl get pods -n mysql -o wide. Pod’и MySQL мають запускатися лише на нодах з лейблом app=mysql та не повинні знаходитись на одній ноді, що підтверджує роботу node affinity та pod anti-affinity.

Перевірте Deployment застосунку, виконавши kubectl get pods -n app -o wide. Pod’и todoapp повинні віддавати перевагу нодам з лейблом app=todoapp та не бути розміщеними на одній ноді, що підтверджує використання preferred node affinity та pod anti-affinity.

На завершення переконайтесь, що всі ресурси перебувають у статусі Running, виконавши kubectl get pods -A. Очікуваний результат — кластер розгорнуто через kind, всі ноди правильно промарковані та затейнчені, а MySQL і todoapp розміщені згідно з заданими affinity та anti-affinity правилами.