# Instruction

## 1. Running the application

To run the application you can use the `bootstrap.sh` script:

```bash
./bootstrap.sh
```

Before running the script, make sure you have granted execute permissions on it:

```bash
chmod +x bootstrap.sh
```

Also, the command may fail if you are in a different directory. In that case you will
need to specify the full path to the script.

## 2. Checking labels and taints on the nodes

First, list the running nodes:

```bash
kubectl get node
```

Example output:

```bash
NAME                 STATUS   ROLES           AGE     VERSION
kind-control-plane   Ready    control-plane   8m29s   v1.36.1
kind-worker          Ready    <none>          8m15s   v1.36.1
kind-worker2         Ready    <none>          8m15s   v1.36.1
kind-worker3         Ready    <none>          8m15s   v1.36.1
kind-worker4         Ready    <none>          8m15s   v1.36.1
kind-worker5         Ready    <none>          8m15s   v1.36.1
kind-worker6         Ready    <none>          8m15s   v1.36.1
```

To see the labels on all nodes at once:

```bash
kubectl get nodes --show-labels
```

Nodes `kind-worker` and `kind-worker2` must have the `app=mysql` label,
the remaining workers must have `app=todoapp`.

Now check both the labels and the taints on a specific node:

```bash
kubectl describe node kind-worker2
```

`kind-worker2` is used here as an example.

Example output (only the relevant part is shown):

```bash
Labels:             app=mysql
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=kind-worker2
                    kubernetes.io/os=linux
Taints:             app=mysql:NoSchedule
```

Look for two sections at the very top:

- `Labels` — contains both the system labels and our own one: `app=mysql`
- `Taints` — must contain `app=mysql:NoSchedule`

To check the taints on all nodes at once:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints[*].key
```

Only `kind-worker` and `kind-worker2` should be tainted with `app`.

## 3. Verifying that the pods were scheduled correctly

```bash
kubectl get pod -n mysql -o wide
```

Expected output:

```bash
NAME      READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
mysql-0   1/1     Running   0          11m     10.244.1.3   kind-worker2   <none>           <none>
mysql-1   1/1     Running   0          7m27s   10.244.6.3   kind-worker    <none>           <none>
```

As you can see, our pods are placed on different nodes — `kind-worker2` and
`kind-worker` — in the `NODE` column.

```bash
kubectl get pod -n todoapp -o wide
```

Expected output:

```bash
NAME                       READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
todoapp-68fd85dd98-fqx6v   1/1     Running   0          11m   10.244.5.2   kind-worker4   <none>           <none>
todoapp-68fd85dd98-w2dj2   1/1     Running   0          11m   10.244.3.2   kind-worker6   <none>           <none>
todoapp-68fd85dd98-w7zd7   1/1     Running   0          11m   10.244.4.2   kind-worker5   <none>           <none>
```

The same applies to the application — all of our pods were successfully started on
different nodes.

## 4. Opening the application in a browser or sending an HTTP request

```bash
curl localhost
```

You should see the application page, or the HTTP response via `curl`.

## 5. Changes made to the original repository

### MySQL probes

The `livenessProbe` and `readinessProbe` in the MySQL StatefulSet were changed.

**Before:**

```yaml
command: ["mysqladmin", "ping"]
```

**After:**

```yaml
command: ["mysqladmin", "-S", "/var/lib/mysql/mysql.sock", "ping"]
```

**Reason:** by default `mysqladmin` looks for the Unix socket at
`/var/run/mysqld/mysqld.sock`, but the MySQL server in this image creates it at
`/var/lib/mysql/mysql.sock`. Because of that both probes always failed with:

```
Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock'
```

The server itself was running correctly — the probes were simply checking the wrong
path. As a result the readiness probe never passed and the liveness probe kept
restarting the container, which put the pod into `CrashLoopBackOff`.

Adding the `-S` flag points `mysqladmin` to the socket the server actually uses.