# Django ToDo list

This is a to-do list web application with the basic features of most web apps, i.e., accounts/login, API, and interactive UI. To do this task, you will need:

- CSS | [Skeleton](http://getskeleton.com/)
- JS  | [jQuery](https://jquery.com/)

## Explore

Try it out by installing the requirements (the following commands work only with Python 3.8 and higher, due to Django 4):

```
pip install -r requirements.txt
```

Create a database schema:

```
python manage.py migrate
```

And then start the server (default is http://localhost:8000):

```
python manage.py runserver
```

You can now browse the [API](http://localhost:8000/api/) or start on the [landing page](http://localhost:8000/).

## Task

Create a Kubernetes manifest for a pod which will contain a ToDo app container:

1. Fork this repository.
1. Use `kind` to spin up a cluster from a `cluster.yml` configuration file.
1. Inspect Nodes for Labels and Taints
1. Taint nodes labeled with `app=mysql` with `app=mysql:NoSchedule`
1. StateFulSet requirements:
    1. Modify StatefulSet so it can be scheduled on the tainted worker nodes
    1. Add Pod Anti-Affinity rule so MySQL could not be scheduled on the same node
    1. Add Node Affinity rule so mysql scheduled on a node with the `app=mysql` label
1. Deployment requirements:
    1. Add Node Affinity Rules to schedule deployment on an `app=todoapp` labeled nodes (Use `PreferedDuringSchedulingIgnoredDuringExecution`)
    1. Add Pod Anti-Affinity rule so deployment could not be scheduled on the same node
1. `bootstrap.sh` should contain all the commands to deploy all the required resources in the cluster
1. Create the `INSTRUCTION.md` file with detailed instructions  on how to validate the changes
1. Create PR with your changes and attach it for validation on a platform.



##### How to deploy
1.Create cluster using kind
```
kind create cluster --config=cluster.yml
```
2.Run file bootstrap.sh
```
bash bootstrap.sh
```
3.Check pods
```
kubectl get pods -o wide -n todoapp
```
4.Check nodes
```
kubectl get nodes --show-labels
```
