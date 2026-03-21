# Validation

## 1) Create cluster
```bash
kind create cluster --config cluster.yml
```

## 2) Deploy all
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

## 3) Check taints
```bash
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```
Expect: `app=mysql:NoSchedule`.

## 4) Check mysql placement
```bash
kubectl -n mysql get pods -o wide
```
Expect: mysql pods on different nodes with `app=mysql`.

## 5) Check todoapp placement
```bash
kubectl -n todoapp get pods -o wide
```
Expect: pods on `app=todoapp` nodes and not on one node (when replicas > 1).

## 6) Check affinity/tolerations
```bash
kubectl -n mysql get sts mysql -o yaml | rg "tolerations|nodeAffinity|podAntiAffinity"
kubectl -n todoapp get deploy todoapp -o yaml | rg "preferredDuringSchedulingIgnoredDuringExecution|podAntiAffinity"
```

## 7) Check ingress
```bash
kubectl -n ingress-nginx get pods
kubectl -n todoapp get ingress
```

## 8) Optional test
```bash
curl -I http://localhost/
```
