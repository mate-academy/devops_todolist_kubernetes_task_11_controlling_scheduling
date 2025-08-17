# Check MySQL:

1. Namespace MySQL

```bash
kubectl get ns
```

Be sure that namespace `mysql` does exist

2. Pods MySQL

```bash
kubectl get pods -n mysql
```

All the pods should have the status `Running`

3. Service MySQL

```bash
kubectl get svc -n mysql
```

Be sure that the service has type `ClusterIP`

4. Check the connection to MySQL

```bash
kubectl exec -it <mysql-pod-name> -n mysql -- mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW_DATABASES;"
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
