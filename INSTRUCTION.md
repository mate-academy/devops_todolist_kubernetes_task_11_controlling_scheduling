# Instruction

## Deploy

```bash
kind create cluster --config cluster.yml
bash bootstrap.sh
```

## Validate

### 1. Check node labels
```bash
kubectl get nodes --show-labels
```
Expected: workers with `app=mysql` and `app=todoapp` labels

### 2. Check node taints
```bash
kubectl describe nodes | grep -A5 Taints
```
Expected: nodes labeled `app=mysql` have taint `app=mysql:NoSchedule`

### 3. Check MySQL pods are scheduled on mysql nodes
```bash
kubectl get pods -n mysql -o wide
```
Expected: mysql pods running on nodes labeled `app=mysql`

### 4. Check MySQL pods are on different nodes
```bash
kubectl get pods -n mysql -o wide
```
Expected: each mysql pod is on a separate node

### 5. Check todoapp pods are scheduled on todoapp nodes
```bash
kubectl get pods -n todoapp -o wide
```
Expected: todoapp pods running on nodes labeled `app=todoapp`

### 6. Check todoapp pods are on different nodes
```bash
kubectl get pods -n todoapp -o wide
```
Expected: each todoapp pod is on a separate node

### 7. Check app is accessible
Open `http://localhost` in browser and verify the app works.
