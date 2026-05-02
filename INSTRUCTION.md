# Scheduling Configuration Verification


## 1. Create cluster
```bash
kind create cluster --config cluster.yml
```


## 2. Deploy resources
```bash
bash ./bootstrap.sh
```


## 3. Verify node labels and taints
To verify labels:
```bash
kubectl get nodes --show-labels
```

To verify taints:
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{'\n'}"
```
Expected:

* Nodes with `app=mysql` label have taint `app=mysql:NoSchedule`
* Nodes with `app=todoapp` label exist


## 4. Verify MySQL scheduling
```bash
kubectl get pods -n mysql -o wide
```

Expected:

* MySQL pods run only on nodes with `app=mysql`
* MySQL pods are on different nodes


## 5. Verify todoapp scheduling
```bash
kubectl get pods -n todoapp -o wide
```

Expected:

* Pods prefer nodes with app=todoapp
* Pods are not scheduled on the same node