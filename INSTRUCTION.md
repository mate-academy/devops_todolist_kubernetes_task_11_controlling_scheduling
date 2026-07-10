Run scripts
kind create cluster --config cluster.yml
./bootstrap.sh
After ingress deployment you should be able to access the app on http://localhost and see the app running.
Check all links what you see.
Inspect labels and taints:
kubectl get nodes --show-labels
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
Run command kubectl get pods -n todoapp -o wide
Run command kubectl get pods -n mysql -o wide
You should see pods in different nodes
