To create all dependencies run:
```
chmod +x bootstrap.sh
./bootstrap.sh
```

To validate if the Affinity and Anti-Affinity work:
```
kubectl get pods -n todoapp -o wide
kubectl get pods -n mysql  -o wide
```
At the column NODE you will see that mysql-pods and todoapp-pods are on different nodes 