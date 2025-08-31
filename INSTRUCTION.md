# Инструкции по валидации Kubernetes Scheduling

## Предварительные требования

1. Установленный `kind` (Kubernetes in Docker)
2. Установленный `kubectl`
3. Установленный `Docker`

## Шаги валидации

### 1. Запуск развертывания

```bash
# Сделать скрипт исполняемым (для Linux/Mac)
chmod +x bootstrap.sh

# Запустить развертывание
./bootstrap.sh
```

### 2. Проверка кластера

```bash
# Проверить статус кластера
kubectl cluster-info

# Проверить ноды и их лейблы
kubectl get nodes --show-labels
```

**Ожидаемый результат:**

- 1 control-plane нода
- 6 worker нод: 2 с лейблом `app=mysql`, 4 с лейблом `app=todoapp`

### 3. Проверка Taints

```bash
# Проверить taint на нодах
kubectl describe nodes | grep -A 5 -B 5 Taints
```

**Ожидаемый результат:**

- Ноды с лейблом `app=mysql` должны иметь taint `app=mysql:NoSchedule`

### 4. Валидация MySQL StatefulSet

```bash
# Проверить MySQL поды
kubectl get pods -l app=mysql -o wide

# Проверить StatefulSet
kubectl get statefulset

# Проверить tolerations и affinity
kubectl describe pod -l app=mysql
```

**Ожидаемые результаты:**

- ✅ 2 MySQL пода запущены
- ✅ Поды размещены только на нодах с лейблом `app=mysql`
- ✅ Поды размещены на разных нодах (Pod Anti-Affinity)
- ✅ Поды имеют tolerations для `app=mysql:NoSchedule`

### 5. Валидация ToDo Deployment

```bash
# Проверить ToDo поды
kubectl get pods -l app=todoapp -o wide

# Проверить Deployment
kubectl get deployment

# Проверить affinity правила
kubectl describe pod -l app=todoapp
```

**Ожидаемые результаты:**

- ✅ 3 ToDo пода запущены
- ✅ Поды предпочтительно размещены на нодах с лейблом `app=todoapp`
- ✅ Поды размещены на разных нодах (Pod Anti-Affinity)
- ✅ Используется `PreferredDuringSchedulingIgnoredDuringExecution`

### 6. Проверка работоспособности

```bash
# Проверить сервисы
kubectl get services

# Проверить доступность приложения
curl http://localhost:30007
```

**Ожидаемый результат:**

- ✅ Приложение доступно по адресу http://localhost:30007

### 7. Детальная валидация Scheduling

```bash
# Проверить события планировщика
kubectl get events --sort-by='.metadata.creationTimestamp'

# Проверить размещение по нодам
echo "=== Размещение MySQL подов ==="
kubectl get pods -l app=mysql -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase

echo "=== Размещение ToDo подов ==="
kubectl get pods -l app=todoapp -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase
```

### 8. Проверка Anti-Affinity правил

```bash
# Проверить, что MySQL поды не на одной ноде
kubectl get pods -l app=mysql -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'

# Проверить, что ToDo поды не на одной ноде
kubectl get pods -l app=todoapp -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'
```

### 9. Очистка ресурсов

```bash
# Удалить кластер после тестирования
kind delete cluster
```

## Критерии успешной валидации

- ✅ Кластер создается с правильной конфигурацией нод
- ✅ Taint применяется к нодам с `app=mysql`
- ✅ MySQL поды размещаются только на tainted нодах
- ✅ MySQL поды не размещаются на одной ноде
- ✅ ToDo поды предпочтительно размещаются на нодах с `app=todoapp`
- ✅ ToDo поды не размещаются на одной ноде
- ✅ Приложение работает и доступно через NodePort

## Возможные проблемы и решения

1. **Поды в состоянии Pending**

   - Проверить tolerations и node affinity
   - Проверить наличие taint на нодах

2. **Поды размещаются на неправильных нодах**

   - Проверить лейблы нод
   - Проверить правила affinity в манифестах

3. **Anti-Affinity не работает**
   - Проверить `topologyKey: "kubernetes.io/hostname"`
   - Убедиться, что лейблы подов правильные
