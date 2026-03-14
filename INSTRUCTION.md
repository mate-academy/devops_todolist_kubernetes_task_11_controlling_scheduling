# Kubernetes Scheduling Validation Guide

## 1. Prerequisites

Make sure these tools are installed:

- `docker`
- `kind`
- `kubectl`
- `git`
- Optional for PR automation: `gh` (GitHub CLI)

## 2. Fork and clone repository

1. Fork the repository in GitHub UI.
2. Clone your fork:

```bash
git clone <YOUR_FORK_URL>
cd devops_todolist_kubernetes_task_11_controlling_scheduling
```

## 3. Bootstrap cluster and deploy resources

Run all provisioning and deployment commands from one script:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

What `bootstrap.sh` does:

- Creates a kind cluster from `cluster.yml` (name: `todoapp-scheduling`).
- Inspects node labels and taints.
- Taints all nodes labeled `app=mysql` with `app=mysql:NoSchedule`.
- Deploys MySQL namespace/resources and StatefulSet.
- Deploys ToDo app namespace/resources and Deployment.
- Installs ingress-nginx and applies ingress resource.

## 4. Validate node labels and taints

```bash
kubectl get nodes --show-labels
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

Expected:

- Some worker nodes have `app=mysql`.
- Some worker nodes have `app=todoapp`.
- Nodes with `app=mysql` show taint `app=mysql:NoSchedule`.

## 5. Validate MySQL StatefulSet scheduling rules

### 5.1 Check pods and node placement

```bash
kubectl -n mysql get pods -l app=mysql -o wide
kubectl -n mysql get pod -l app=mysql -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'
```

Expected:

- MySQL pods are running.
- MySQL replicas are on different nodes (pod anti-affinity).

### 5.2 Confirm mysql pods run only on mysql-labeled nodes

```bash
for node in $(kubectl -n mysql get pod -l app=mysql -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}'); do
  kubectl get node "$node" -o jsonpath='{.metadata.name}{" labels: "}{.metadata.labels.app}{"\n"}'
done
```

Expected:

- Every printed node has label value `mysql` for key `app`.

### 5.3 Confirm StatefulSet spec contains toleration + affinities

```bash
kubectl -n mysql get statefulset mysql -o yaml | grep -nE "tolerations|nodeAffinity|podAntiAffinity|topologyKey|NoSchedule"
```

Expected:

- `tolerations` for `app=mysql:NoSchedule`.
- `nodeAffinity` requiring label `app=mysql`.
- `podAntiAffinity` with `topologyKey: kubernetes.io/hostname`.

## 6. Validate ToDo Deployment scheduling rules

### 6.1 Check deployment and pod placement

```bash
kubectl -n todoapp get deploy todoapp
kubectl -n todoapp get pods -l app=todoapp -o wide
kubectl -n todoapp get pod -l app=todoapp -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\n"}{end}'
```

Expected:

- Deployment has at least 2 replicas.
- Pods are on different nodes (pod anti-affinity).

### 6.2 Confirm todoapp pods are placed on preferred `app=todoapp` nodes

```bash
for node in $(kubectl -n todoapp get pod -l app=todoapp -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}'); do
  kubectl get node "$node" -o jsonpath='{.metadata.name}{" labels: "}{.metadata.labels.app}{"\n"}'
done
```

Expected:

- Nodes should show label value `todoapp` for key `app` (preferred node affinity).

### 6.3 Confirm Deployment spec contains preferred node affinity + pod anti-affinity

```bash
kubectl -n todoapp get deploy todoapp -o yaml | grep -nE "preferredDuringSchedulingIgnoredDuringExecution|nodeAffinity|podAntiAffinity|topologyKey"
```

Expected:

- `nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution` for `app=todoapp`.
- `podAntiAffinity.requiredDuringSchedulingIgnoredDuringExecution` for `app=todoapp`.

## 7. Validate app availability

```bash
kubectl -n todoapp get svc
```

Open in browser:

- `http://localhost:30007`

## 8. Commit and create PR

```bash
git checkout -b feat/scheduling-rules
git add bootstrap.sh .infrastructure/app/deployment.yml .infrastructure/mysql/statefulSet.yml INSTRUCTION.md
git commit -m "Add taints, affinities, anti-affinities and validation guide"
git push origin feat/scheduling-rules
```

Create PR:

- With GitHub UI from your fork branch to target repository branch, or
- With GitHub CLI:

```bash
gh pr create --fill
```
