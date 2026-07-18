# Validation Instructions

These steps verify node labeling/tainting and that the MySQL `StatefulSet` and
ToDo app `Deployment` are scheduled according to the required affinity /
anti-affinity / toleration rules.

## Prerequisites

- Docker running locally
- `kind` installed
- `kubectl` installed

## 1. Create the cluster

```bash
kind create cluster --config cluster.yml
```

This brings up 1 control-plane node and 2 worker nodes. The workers get their
labels automatically at join time (baked into `cluster.yml` via kubeadm's
`JoinConfiguration.nodeRegistration.kubeletExtraArgs.node-labels`):

- one worker → `app=mysql`
- one worker → `app=todoapp`

## 2. Inspect node labels and taints (before bootstrap)

```bash
kubectl get nodes --show-labels
kubectl describe nodes | grep -E "Name:|Taints:"
```

Expected at this point:

- One worker node shows `app=mysql` in its labels.
- The other worker node shows `app=todoapp` in its labels.
- No custom taints yet (only the default control-plane `NoSchedule` taint on
  `kind-control-plane`).

## 3. Run the bootstrap script

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

This will, in order:

1. Print node labels/taints again for reference.
2. **Taint** the node(s) labeled `app=mysql` with `app=mysql:NoSchedule`
   (`kubectl taint nodes -l app=mysql app=mysql:NoSchedule`).
3. Deploy the `mysql` namespace, secrets, config, headless service and the
   `StatefulSet`.
4. Deploy the `todoapp` namespace, PV/PVC, secret, config, `ClusterIP`/
   `NodePort` services, `HorizontalPodAutoscaler` and `Deployment`.
5. Install the `ingress-nginx` controller, wait for it to be ready, and apply
   `ingress.yml`.

## 4. Verify the taint was applied

```bash
kubectl describe node <mysql-node-name> | grep -A2 "Taints:"
```

Expected: `app=mysql:NoSchedule`.

## 5. Verify MySQL StatefulSet scheduling

```bash
kubectl get pods -n mysql -o wide
```

Check:

- Every `mysql-N` pod that is `Running` is placed on the node labeled
  `app=mysql` (the tainted one) — confirms the toleration + required node
  affinity are working together (the toleration lets the pod past the taint,
  the node affinity then pins it to that specific node).
- No two `mysql-N` pods share the same node — confirms the required
  pod anti-affinity (`topologyKey: kubernetes.io/hostname`).

> **Note:** the `StatefulSet` requests 3 replicas, but with a single node
> labeled `app=mysql`, the strict node affinity (only that node) combined with
> the strict pod anti-affinity (no two mysql pods per node) means only
> **one** `mysql-N` pod can be `Running` at a time — the rest will stay
> `Pending`. This is expected: it demonstrates that both rules are being
> enforced together, rather than the deployment silently ignoring one of
> them. Confirm the pending reason with:
> ```bash
> kubectl describe pod mysql-1 -n mysql
> ```
> The `Events` section should show something like *"didn't match pod
> anti-affinity rules"* or *"node(s) didn't match Pod's node affinity"*.

## 6. Verify ToDo app Deployment scheduling

```bash
kubectl get pods -n todoapp -o wide
```

Check:

- Running `todoapp` pods land on the node labeled `app=todoapp` when
  possible — this is a **preferred** (soft) node affinity rule, so the
  scheduler will fall back to another untainted node if the preferred one is
  full, but will not violate it needlessly.
- No two `todoapp` pods share the same node — confirms the required pod
  anti-affinity rule for the deployment.

## 7. Confirm app is still reachable end-to-end

```bash
curl -i http://localhost/
curl -i http://localhost/api/
```

Both should return `200`, not `404`, confirming the ingress → service → pod
path still works after the scheduling changes.

## 8. Tear down (optional)

```bash
kind delete cluster --name kind
```

## Summary checklist

- [ ] `cluster.yml` creates 1 control-plane + 2 worker nodes
- [ ] One worker is labeled `app=mysql`, the other `app=todoapp`
- [ ] `bootstrap.sh` taints the `app=mysql` node with `app=mysql:NoSchedule`
- [ ] `mysql` `StatefulSet` has a toleration for that taint
- [ ] `mysql` `StatefulSet` has a required node affinity for `app=mysql`
- [ ] `mysql` `StatefulSet` has a required pod anti-affinity on
      `kubernetes.io/hostname`
- [ ] `todoapp` `Deployment` has a **preferred** node affinity for
      `app=todoapp`
- [ ] `todoapp` `Deployment` has a required pod anti-affinity on
      `kubernetes.io/hostname`
- [ ] `http://localhost` still serves the app with no 404s after all
      scheduling changes