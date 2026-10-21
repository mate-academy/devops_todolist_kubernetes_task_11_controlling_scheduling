# Validation instructions

## 1. Create the cluster and deploy resources

```bash
kind create cluster --config cluster.yml
bash bootstrap.sh
```

## 2. Check node labels and taints

```bash
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Expected: nodes labeled `app=mysql` have the taint `app=mysql:NoSchedule`.

## 3. Check MySQL StatefulSet placement

```bash
kubectl get pods -n mysql -o wide
```

Expected:
- all MySQL pods run only on nodes labeled `app=mysql` (node affinity + toleration);
- each MySQL pod runs on a different node (pod anti-affinity).

## 4. Check ToDo app Deployment placement

```bash
kubectl get pods -n todoapp -o wide
```

Expected:
- pods are preferably scheduled on nodes labeled `app=todoapp` (preferred node affinity);
- each pod runs on a different node (pod anti-affinity).

## 5. Check the affinity rules in the live objects

```bash
kubectl get statefulset mysql -n mysql -o jsonpath='{.spec.template.spec.affinity}'
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.affinity}'
```

## Note

The ToDo app may restart once or twice on first start while MySQL is not ready yet. This is expected; pods become `1/1 Running` after MySQL is up.