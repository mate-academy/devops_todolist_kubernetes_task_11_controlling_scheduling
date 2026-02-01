Preconditions
```bash
kind create cluster --config cluster.yml
./bootstrap.sh
kubectl apply -f .infrastructure/ingress/ingress.yml
```

Check all nodes and their taints
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```
Add tains to worker with label app=mysql
```bash
kubectl taint nodes $(kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}') app=mysql:NoSchedule
```
Check all nodes and their taints, again to see results
```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```
Check that mysql pods on workers with app=mysql labels and each pod on different worker
```bash
kubectl get pods -n mysql -o wide
```
Check that todoapp pods on workers with app=todoapp labels and each pod on different worker
```bash
kubectl get pods -n todoapp -o wide
```