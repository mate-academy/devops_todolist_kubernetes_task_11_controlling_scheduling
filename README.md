1. You could recreate cluster if you need it by running command below

```
kind delete cluster
kind create cluster --config cluster.yml
```

2. To deploying all the required resources in the cluster run command

```
sh bootstrap.sh
```

3. Now you can enjoy fantastic todo application on http://localhost/ or http://127.0.0.1

4. For validating task get all labels of working nodes

```
kubectl get nodes --show-labels
```

5. Check for working pods with mysql on kind-worker and kind-worker2 only

```
kubectl get pods -o wide -n mysql
```

6. Check for working pods with todoapp on any nodes except kind-worker and kind-worker2

```
kubectl get pods -o wide -n todoapp
```
