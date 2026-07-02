# Instructions

## Deploy

```bash
bash bootstrap.sh
```

## Validate

### 1. Check node labels and taints

```bash
kubectl get nodes --show-labels
kubectl describe nodes -l app=mysql | grep -A5 Taints
```

Expected: nodes with `app=mysql` label have taint `app=mysql:NoSchedule`

### 2. MySQL pods scheduled only on mysql nodes

```bash
kubectl get pods -n mysql -o wide
```

Expected: все поды mysql запущены на нодах с лейблом `app=mysql`,
каждый под на отдельной ноде (podAntiAffinity)

### 3. TodoApp pods scheduled on todoapp nodes

```bash
kubectl get pods -n todoapp -o wide
```

Expected: поды todoapp запущены на нодах с лейблом `app=todoapp`

### 4. App is running

```bash
kubectl get pods -n todoapp
kubectl get pods -n mysql
```

Expected: все поды в статусе `Running`, `READY 1/1`

### 5. App is accessible

Открой в браузере: http://localhost