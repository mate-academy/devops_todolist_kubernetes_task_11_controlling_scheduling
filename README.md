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

---
### Delpoy

Use:
```bash
./bootstrap.sh
```
```yaml
...
pod/ingress-nginx-controller-5fd8d8557c-zzww2 condition met
ingress.networking.k8s.io/todoapp-ingress created
```
Now you can start on the [landing page](http://localhost/) or browse the [API](http://localhost:/api/)

### Validate:

All required nodes are properly tainted:

```bash
kubectl get nodes -o go-template='{{range .items}}{{.metadata.name}}{{"\n  Labels:"}}{{range $key, $value := .metadata.labels}}{{"\n    "}}{{$key}}={{$value}}{{end}}{{"\n  Taints:"}}{{range .spec.taints}}{{"\n    "}}{{.key}}={{.value}}:{{.effect}}{{end}}{{"\n\n"}}{{end}}'
```
```yaml
kind-control-plane
  Labels:
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    ingress-ready=true
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-control-plane
    kubernetes.io/os=linux
    node-role.kubernetes.io/control-plane=
    node.kubernetes.io/exclude-from-external-load-balancers=
  Taints:
    node-role.kubernetes.io/control-plane=<no value>:NoSchedule

kind-worker
  Labels:
    app=mysql
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-worker
    kubernetes.io/os=linux
  Taints:
    app=mysql:NoSchedule

kind-worker2
  Labels:
    app=mysql
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-worker2
    kubernetes.io/os=linux
  Taints:
    app=mysql:NoSchedule

kind-worker3
  Labels:
    app=todoapp
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-worker3
    kubernetes.io/os=linux
  Taints:

kind-worker4
  Labels:
    app=todoapp
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-worker4
    kubernetes.io/os=linux
  Taints:

kind-worker5
  Labels:
    app=todoapp
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-worker5
    kubernetes.io/os=linux
  Taints:

kind-worker6
  Labels:
    beta.kubernetes.io/arch=amd64
    beta.kubernetes.io/os=linux
    kubernetes.io/arch=amd64
    kubernetes.io/hostname=kind-worker6
    kubernetes.io/os=linux
  Taints:
```
All pods are runing on the right nodes:
```bash
kubectl get pods -o wide -A | grep -E 'NAMESPACE|mysql|todoapp'
```
```yaml
NAMESPACE            NAME                                         READY   STATUS      RESTARTS   AGE   IP           NODE                 NOMINATED NODE   READINESS GATES
mysql                mysql-0                                      1/1     Running     0          26m   10.244.2.3   kind-worker2         <none>           <none>
mysql                mysql-1                                      1/1     Running     0          23m   10.244.3.3   kind-worker          <none>           <none>
todoapp              todoapp-79bc65d548-8kddd                     1/1     Running     0          26m   10.244.1.2   kind-worker4         <none>           <none>
todoapp              todoapp-79bc65d548-qjcgc                     1/1     Running     0          26m   10.244.6.3   kind-worker5         <none>           <none>
```
