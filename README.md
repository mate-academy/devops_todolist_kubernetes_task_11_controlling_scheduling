# Django ToDo list

# Validate the changes 
1. Run `bootstrap.sh`
2. Create a cluster using the command `kind create cluster --config cluster.yml`. If you have another cluster, delete it first using `kind delete cluster`.
3. Write in the terminal `kubectl taint nodes kind-worker2 kind-worker3 app=mysql:NoSchedule`
4. Get all taints on all nods `kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[*]}{'\n'}`
5. Use `kubectl label nodes kind-worker kind-worker2 kind-worker3 kind-worker4` to label nodes
6. View all labels with the command `kubectl get nodes --show-labels`
7. Use `kubectl get pods -n mateapp -o wide` to see results
