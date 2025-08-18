# Check MySQL:

1. Namespace MySQL

```bash
kubectl get ns
```

Be sure that namespace `mysql` does exist

2. Pods MySQL

```bash
kubectl get pods -n mysql -o wide
```

All the pods should have the status `Running`

3. Node labels

```bash
kubectl get nodes --show-labels | grep mysql
```

Be sure that the nodes with podes have label `app=mysql`

4. Service MySQL

```bash
kubectl get svc -n mysql
```

Be sure that the service has type `ClusterIP`

5. Check the connection to MySQL

```bash
kubectl exec -it <mysql-pod-name> -n mysql -- mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW_DATABASES;"
```

6. Tolerations / Taints

```bash
kubectl describe pod <mysql-pod-name> -n mysql | grep -A5 Tolerations
kubectl describe node <mysql-node-name> | grep Taints
```

# Check ToDoApp:

1. Todo namespace

```bash
kubectl get ns
```

Namespace `todoapp` should exist

2. PV and PVC

```bash
kubectl get pv -n todoapp
kubectl get pvc -n todoapp
```

Check that PV and PVC were created and `STATUS: Bound`

3. Secret and ConfigMap

```bash
kubectl get secret -n todoapp
kubectl get configmap -n todoapp
```

4. Deployment:

```bash
kubectl get deployment -n todoapp
kubectl get pods -n todoapp
```

5. Affinity / Anti-Affinity

```bash
kubectl describe pod <todoapp-pod-name> -n todoapp | grep -A10 "Affinity"
```
