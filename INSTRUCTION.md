# Validate scheduling rules

## 1. Create the cluster and deploy
```bash
kind delete cluster   # only if a cluster "kind" already exists
chmod +x bootstrap.sh
./bootstrap.sh
```
`bootstrap.sh` creates the kind cluster from `cluster.yml`, taints `app=mysql` nodes with `app=mysql:NoSchedule` and applies all manifests.

## 2. Inspect node labels and taints
```bash
kubectl get nodes --show-labels
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{\"\n\"}"
```
Workers 1–2 have `app=mysql`, workers 3–5 have `app=todoapp`.

## 3. Check taints
```bash
kubectl get nodes -l app=mysql -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints}{\"\n\"}"
```
Both nodes must have `{"effect":"NoSchedule","key":"app","value":"mysql"}`.

## 4. Check MySQL placement
```bash
kubectl get pods -n mysql -o wide
```
- `mysql-0` and `mysql-1` are `Running` on the two `app=mysql` nodes (toleration + node affinity).
- They are on different nodes (pod anti-affinity).

## 5. Check ToDo app placement
```bash
kubectl get pods -n todoapp -o wide
```
- Pods run on `app=todoapp` nodes (preferred node affinity).
- No todoapp pod runs on a node with a MySQL pod (pod anti-affinity to `app=mysql` pods in namespace `mysql`).
- No todoapp pods on `app=mysql` nodes (they have no toleration).

## 6. Check the app
```bash
kubectl port-forward -n todoapp svc/todoapp-service 8080:80
```
Open http://localhost:8080