# Testing Django ToDo app
## Validating labels
To validate labels run this command:
```bash
kubectl get nodes --show-labels
```
## Validating affinity rules
```bash
kubectl get pods -n todoapp -o wide
```
```bash
kubectl get pods -n mysql -o wide
```