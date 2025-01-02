# Kubernetes Cluster Setup Instructions

Це інструкція для налаштування кластера Kubernetes з використанням `kind` для деплойменту MySQL та TodoApp з усіма необхідними конфігураціями та ресурсами.

## 1. Підготовка Kubernetes кластеру за допомогою (kind)

Для створення локального кластеру Kubernetes використовується утиліта (kind). Виконайте наступні кроки:

1.1. Спочатку створіть кластер, використовуючи конфігурацію в файлі (cluster.yml):

  kind create cluster --config cluster.yml

2. Розгортання ресурсів Kubernetes
Після створення кластера, застосуйте конфігураційні файли для розгортання MySQL, TodoApp та інших необхідних ресурсів. Це можна зробити за допомогою скрипту bootstrap.sh.

2.1.Виконайте команду для застосування ресурсів:

  bash bootstrap.sh

Цей скрипт виконає наступні дії:

 - Створить простір імен для MySQL та TodoApp.
 - Створить необхідні ConfigMap та Secret для конфігурацій та паролів.
- Розгорне StatefulSet для MySQL з Node Affinity та Pod Anti-Affinity.
 - Розгорне Deployment для TodoApp з Node Affinity та Pod Anti-Affinity.
 - Створить сервіс для доступу до MySQL та TodoApp.
 - Налаштує горизонтальне масштабування для TodoApp.
 - Встановить Ingress Controller для доступу ззовні.

3. Перевірка статусу ресурсів

Після розгортання перевірте статус ресурсів:

3.1. Перевірка стану подів:

  kubectl get pods -n mysql
  kubectl get pods -n todoapp

Переконайтеся, що всі поди працюють і мають статус Running.

3.2. Перевірка сервісів:

  kubectl get svc -n mysql
  kubectl get svc -n todoapp

Перевірте, що сервіси MySQL та TodoApp доступні та правильно налаштовані.

3.3. Перевірка StatefulSet і Deployment:

  kubectl get statefulset mysql -n mysql
  kubectl get deployment todoapp -n todoapp

Переконайтеся, що StatefulSet для MySQL та Deployment для TodoApp налаштовані правильно.

3.4. Перевірка Horizontal Pod Autoscaler:

  kubectl get hpa -n todoapp

Перевірте, чи працює горизонтальне масштабування для TodoApp.

3.5. Перевірка Ingress:

  kubectl get ingress -n todoapp

Переконайтеся, що Ingress налаштовано для доступу до TodoApp ззовні.

4. Технічні зауваження та можливі проблеми

4.1. Перевірка логів:
Якщо поди не запускаються або мають помилки, перевірте логи:

  kubectl logs <pod_name> -n <namespace>

4.2. Перевірка стану вузлів:
Перевірте статус вузлів у кластері:

  kubectl get nodes

Якщо вузли мають проблеми, перевірте їхні логи та конфігурацію.

4.3. Тейнти для MySQL:
Якщо вам потрібно заблокувати розміщення інших подів на вузлах, де працює MySQL, використовуйте команду:

  kubectl taint nodes -l app=mysql app=mysql:NoSchedule

4.4. Проблеми з Ingress:

Якщо Ingress не працює, перевірте логи Ingress Controller:

  kubectl logs <ingress-pod-name> -n ingress-nginx 

5. Завершення налаштування
Після того як всі ресурси будуть налаштовані та перевірені, ваш кластер Kubernetes буде готовий до використання для розгортання програми TodoApp з базою даних MySQL.

Не забувайте перевіряти статуси подів та ресурсів через kubectl для переконання в правильному налаштуванні середовища.

6. Додаткові ресурси
Документація Kubernetes
Документація для Ingress
Документація для kind


### Деталі файлів:

- **`bootstrap.sh`** запускає всі необхідні ресурси Kubernetes, включаючи розгортання бази даних та додатка.
- **`cluster.yml`** містить конфігурацію для створення кластера за допомогою `kind`.
- Інші файли, як-от `statefulSet.yml`, `deployment.yml`, `service.yml` тощо, вже були включені у попередніх повідомленнях.

Цей файл інструкції описує всі кроки для налаштування, розгортання та перевірки Kubernetes-кластера з усіма необхідними ресурсами та налаштуваннями.





