# Django ToDo list

This is a todo list web application with basic features of most web apps, i.e., accounts/login, API, and interactive UI. To do this task, you will need:

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

Now you can browse the [API](http://localhost:8000/api/) or start on the [landing page](http://localhost:8000/).

## Task

Create a kubernetes manifest for a pod which will containa ToDo app container:

1. Fork this repository.
1. Use `kind` to spin up a cluster from a `cluster.yml` configuration file.
1. Inspect Nodes for Labels and Taints
1. Taint nodes labeled with `app=mysql` with `app=mysql:NoSchedule`
1. StateFulSet requirements:
    1. Modify StatefulSet so it can be scheduled on the tainted worder nodes
    1. Add Pod Anti-Affinity rule so mysql could not be scheduled on the same node
    1. Add Node Affinity rule so mysql scheduled on a node with `app=mysql` label
1. Deployment requirements:
    1. Add Node Affinity Rules to schedule deployment on a `app=todoapp` labeled nodes (Use `PreferedDuringSchedulingIgnoredDuringExecution`)
    1. Add Pod Anti-Affinity rule so deployment could not be scheduled on the same node
1. `bootstrap.sh` should containe all the commands to deploy all the required resources in the cluster
1. `README.md` should have instructuions on how to validate the changes
1. Create PR with your changes and attach it for validation on a platform.



To start project use:
```sh
./bootstrap.sh
```

For a project resources validation use:
```sh
./validation.sh
``` 