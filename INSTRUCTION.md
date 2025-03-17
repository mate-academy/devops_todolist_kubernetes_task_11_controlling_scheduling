To deploy our app you should simply run bootstrap.sh in your terminal, previously add execution permissions to this file.

To check that everything is done right, do the following steps:

Check the labels of the nodes:
```
kubectl get nodes --show-labels
```

Then check, that our pods were started on the proper nodes:
```
kubectl get pods -n todoapp -o wide
```
```
kubectl get pods -n mysql -o wide
```