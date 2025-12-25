# Інструкція 

План дій
- Створити кластер (рекомендовано: kind + використання `cluster.yml`)
- Запустити `bootstrap.sh` для застосування всіх ресурсів
- Перевірити стан ресурсів (pods, services, ingress)
- Виконати прості запити до додатку і перевірити логи

1) Створення кластера з kind (рекомендовано)
- Якщо у вас в корені проекту є `cluster.yml`, використайте його. Команда (cmd.exe):

```cmd
kind create cluster --config "%CD%\cluster.yml" --name todolist-cluster
```

`--config` використовує локальний `cluster.yml`. Ім'я кластера — будь-яке.

2) Налаштування kubectl-контексту
Після створення переконайтеся, що kubectl підключений до нового кластера:

```cmd
kubectl cluster-info --context kind-todolist-cluster
kubectl config get-contexts
kubectl get nodes
```

(замініть `kind-todolist-cluster` на реальне ім'я контексту).

3) Запуск `bootstrap.sh`
Файл `bootstrap.sh` містить послідовність `kubectl apply` і додаткові дії — його потрібно запускати в bash-оточенні.

Git Bash або інша bash-оболонка (рекомендовано):

```
./bootstrap.sh
```

Скрипт за замовчуванням робить `kubectl apply` для папок `.infrastructure/` та встановлює ingress-nginx з офіційного маніфесту. 



4) Очікування та перевірка ресурсів
Після виконання скрипта почекайте, поки pods стануть Ready. Перевірте:

```cmd
kubectl get namespaces
kubectl get pods --all-namespaces
kubectl get svc --all-namespaces
kubectl get deployments --all-namespaces
kubectl get statefulsets --all-namespaces
kubectl get ingress --all-namespaces
```

6) Перевірка логіки роботи додатку
Перевіримо розташування подів на вузлах:

```cmd
kubectl get pods -o wide -n mysql
kubectl get pods -o wide -n todoapp
```

7) Зупинка і видалення кластера
Якщо кластер створено через kind, видалити його легко:

```cmd
kind delete cluster --name todolist-cluster
```

