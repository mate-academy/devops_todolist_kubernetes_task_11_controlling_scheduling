```bash
kind create cluster --name todo-lab --config cluster.yml
```
Verify nodes:

```bash
kubectl get nodes
```
Inspect Node Labels

```bash
kubectl get nodes -L app
```
Apply MySQL taints:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
```

Validate:

```bash
kubectl describe nodes -l app=mysql
```
Deploy Resources
Run:

```bash
bash bootstrap.sh
```
Validate MySQL StatefulSet

```bash
kubectl get statefulset mysql -n mysql
kubectl get pods -n mysql -o wide
```
Validate MySQL Node Affinity

```bash
kubectl get statefulset mysql -n mysql -o yaml
```

Validate MySQL Tolerations

```bash
kubectl describe statefulset mysql -n mysql
```
Validate MySQL Pod Anti-Affinity

```bash
kubectl get pods -n mysql -o wide
```

Validate Django Node Affinity

```bash
kubectl get deployment todoapp -n todoapp -o yaml
```
Validate Django Pod Anti-Affinity

```bash
kubectl get deployment todoapp -n todoapp -o yaml
```