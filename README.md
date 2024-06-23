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
    1. Add Node Affinity Rules to schedule deployment on a `app=todoapp` labeled nodes (Use `preferredDuringSchedulingIgnoredDuringExecution`)
    1. Add Pod Anti-Affinity rule so deployment could not be scheduled on the same node
1. `bootstrap.sh` should containe all the commands to deploy all the required resources in the cluster
1. `README.md` should have instructuions on how to validate the changes
1. Create PR with your changes and attach it for validation on a platform.

---

# SOLUTION

1. First of all the syntax of the rules implied is correct since the manifests were succesfully applied
2. To validate that the taints have been created

    * we use following command

      ```
      kubectl get nodes -o go-template='{{range .items}}{{.metadata.name}}{{"\n  Labels:"}}{{range $key, $value := .metadata.labels}}{{"\n    "}}{{$key}}={{$value}}{{end}}{{"\n  Taints:"}}{{range .spec.taints}}{{"\n    "}}{{.key}}={{.value}}:{{.effect}}{{end}}{{"\n\n"}}{{end}}'
      ```
    * with the following output

      ```
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
3. To validate that pods were created in proper nodes

    we use following comands

    ```
    kubectl get pods -n mysql -o wide         

    [OUTPUT]
    NAME      READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    mysql-0   1/1     Running   0          64m   10.244.1.3   kind-worker2   <none>           <none>
    mysql-1   1/1     Running   0          64m   10.244.4.3   kind-worker    <none>           <none>
    ```

    ```
    kubectl get pods -n todoapp -o wide

    [OUTPUT]
    NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    todoapp-79bc65d548-5znx9   1/1     Running   0          28m   10.244.5.2   kind-worker3   <none>           <none>
    todoapp-79bc65d548-gngmj   1/1     Running   0          28m   10.244.2.2   kind-worker5   <none>           <none>
    ```
