1. Run scripts
kind create cluster --config cluster.yml
./bootstrap.sh
2. After ingress deployment you should be able to access the app on http://localhost and see the app running.
Check all links what you see.
3. Inspect labels and taints:
Check labels, use command
kubectl get nodes --show-labels
If labels app=mysql and   not exists, use commands:
kubectl label nodes kind-worker kind-worker2 app=mysql
kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp

Chack that nodes are tainted
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}" or
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name}{' '}{.spec.taints}{'\n'}{end}" if powershell environment
Chack that pods are in different nodes.
Run command: kubectl get pods -n todoapp -o wide
Run command: kubectl get pods -n mysql -o wide
You should see pods in different nodes.

Another commands:
kubectl delete statefulset mysql -n mysql
kubectl rollout restart deployment todoapp