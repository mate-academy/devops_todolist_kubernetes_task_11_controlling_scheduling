# Інструкція з перевірки розгортання та правил планера (Scheduling)

# 1. Підготовка та розгортання кластера
Запустить скрипт `bootstrap.sh`, який створить кластер Kind з файлу `cluster.yml` та застосує всі маніфести:
```bash
   bash bootstrap.sh

Перевірте, що ноди мають відповідні мітки (app=mysql та app=todoapp):
kubectl get nodes --show-labels

Перевірте наявність Taints на нодах:
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

MySQL (StatefulSet).Запустіть команду перевірки подів у namespace mysql:
kubectl get pods -n mysql -o wide

TodoApp (Deployment).Запустіть команду перевірки подів у namespace todoapp:
kubectl get pods -n todoapp -o wide

Для видалення створеного кластера виконайте:
kind delete cluster