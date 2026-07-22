# Preparation

Before validation, deploy all required Kubernetes resources using the `bootstrap.sh` script.

Make the script executable:

```bash
chmod +x bootstrap.sh
```

Run the script from the root directory of the repository:

```bash
./bootstrap.sh
```

# Validation

## Check node labels

Run:

```bash
kubectl get nodes --show-labels
```

Verify that:

- two worker nodes have the label `app=mysql`;
- three worker nodes have the label `app=todoapp`;
- one worker node has no `app` label.

## Check node taints

Run:

```bash
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```

Verify that nodes labeled with `app=mysql` have the taint:

```text
app=mysql:NoSchedule
```

## Check MySQL Pods

Run:

```bash
kubectl get pods -n mysql -o wide
```

Verify that:

- both MySQL Pods are running;
- the MySQL Pods are scheduled on different nodes;
- both nodes have the label `app=mysql`.

## Check todoapp Pods

Run:

```bash
kubectl get pods -n todoapp -o wide
```

Verify that:

- all todoapp Pods are running;
- the todoapp Pods are scheduled on different nodes;
- the Pods are scheduled on nodes labeled with `app=todoapp` whenever possible.