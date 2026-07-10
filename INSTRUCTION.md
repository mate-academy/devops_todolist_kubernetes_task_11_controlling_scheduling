# INSTRUCTION.md

## Start

```bash
kind create cluster --config cluster.yml
chmod +x bootstrap.sh
./bootstrap.sh
```

## Check resources

```bash
kubectl get nodes --show-labels
kubectl get pods -A -o wide
kubectl get svc
```

## Open the ToDo application

```bash
kubectl port-forward svc/todoapp 8080:80
```

Open:

```
http://localhost:8080
```