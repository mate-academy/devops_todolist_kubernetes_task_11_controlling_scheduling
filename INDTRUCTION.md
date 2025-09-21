# INSTRUCTION.md
## How to Validate the Kubernetes Scheduling and Affinity Setup

### 1. Prerequisites

- Docker and `kind` installed
- `kubectl` installed
- All manifests updated as per the requirements

---

### 2. Create the Kubernetes Cluster

```sh
kind create cluster --config cluster.yml
```

---

### 3. Apply All Manifests

Run the bootstrap script to deploy all resources:

```sh
chmod +x bootstrap.sh
./bootstrap.sh
```

---

### 4. Validate Node Labels and Taints

Check node labels:

```sh
kubectl get nodes --show-labels
```

Check node taints:

```sh
kubectl get nodes -o json | jq '.items[].spec.taints'
```

Ensure nodes with `app=mysql` label are tainted with `app=mysql:NoSchedule`.

---

### 5. Validate MySQL StatefulSet Scheduling

Check MySQL pods are running:

```sh
kubectl get pods -n mysql -l app=mysql -o wide
```

Verify each pod is scheduled on a node with the `app=mysql` label:

```sh
kubectl get pod -n mysql -l app=mysql -o wide
kubectl get nodes --show-labels
```

Ensure no two MySQL pods are on the same node (pod anti-affinity).

---

### 6. Validate ToDo App Deployment Scheduling

Check ToDo app pods:

```sh
kubectl get pods -n todoapp -l app=todoapp -o wide
```

Verify pods are scheduled on nodes with the `app=todoapp` label (preferred node affinity).

Ensure no two ToDo app pods are on the same node (pod anti-affinity).

---

### 7. Test Application Access

- Access the Django ToDo app via NodePort or Ingress as configured.
- Access the API endpoint and landing page.

---

### 8. Clean Up

To delete the cluster:

```sh
kind delete cluster
```

---

## Notes

- If pods are not scheduled as expected, check events:
  ```sh
  kubectl describe pod <pod-name> -n <namespace>
  ```
- For troubleshooting, review affinity and toleration sections in the manifest files.

---