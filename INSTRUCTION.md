# Kubernetes Scheduling

## 1. Start cluster

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 2. Label nodes

Label MySQL node:

```bash
kubectl label node kind-worker app=mysql --overwrite
```

Label TodoApp node:

```bash
kubectl label node kind-worker2 app=todoapp --overwrite
```

Check labels:

```bash
kubectl get nodes --show-labels
```

## 3. Check taints

Taint MySQL nodes:

```bash
kubectl get nodes -l app=mysql -o name | xargs -I{} kubectl taint nodes {} app=mysql:NoSchedule --overwrite
```

Check taints:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

## 4. Check MySQL

```bash
kubectl get pods -n mysql -o wide
kubectl get statefulset -n mysql
```

MySQL Pods must run on `app=mysql` nodes and on different nodes.

## 5. Check TodoApp

```bash
kubectl get pods -n todoapp -o wide
kubectl get deployment -n todoapp
```

TodoApp Pods should prefer `app=todoapp` nodes and should not run on the same node.

## 6. Final check

```bash
kubectl get pods -A -o wide
```

All required Pods should be in `Running` status.
