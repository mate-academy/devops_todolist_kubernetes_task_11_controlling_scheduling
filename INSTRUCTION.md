# Validating the scheduling changes

## 1. Create the cluster and deploy everything

```
bash bootstrap.sh
```

The script creates the `kind` cluster from `cluster.yml`, taints the `app=mysql` nodes
with `app=mysql:NoSchedule` and applies all manifests.

## 2. Inspect node labels and taints

```
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "^Name:|Taints:"
```

Expected: the two workers labeled `app=mysql` have the taint `app=mysql:NoSchedule`;
the workers labeled `app=todoapp` have no such taint.

## 3. MySQL StatefulSet

```
kubectl get pods -n mysql -o wide
```

Expected:
- both `mysql-*` pods run on the nodes labeled `app=mysql` (tolerations + node affinity);
- each pod runs on a different node (pod anti-affinity on `kubernetes.io/hostname`).

Check the rules in the spec:

```
kubectl get statefulset mysql -n mysql -o jsonpath='{.spec.template.spec.tolerations}{"\n"}{.spec.template.spec.affinity}'
```

## 4. ToDo app Deployment

```
kubectl get pods -n todoapp -o wide
```

Expected:
- pods are placed preferably on the nodes labeled `app=todoapp` (preferred node affinity);
- no two pods share a node (required pod anti-affinity). If replicas exceed the number
  of eligible nodes, the extra pods stay `Pending`.

Check the rules in the spec:

```
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.affinity}'
```

## 5. Negative check (taint works)

```
kubectl run test --image=nginx --overrides='{"spec":{"nodeSelector":{"app":"mysql"}}}'
kubectl describe pod test
```

Expected: the pod is `Pending` with an event like
`node(s) had untolerated taint {app: mysql}`. Clean up with `kubectl delete pod test`.

## 6. Cleanup

```
kind delete cluster
```
