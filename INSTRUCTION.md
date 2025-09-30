# Instructions for Validation

Follow the steps below to validate the deployment and configuration of the ToDo application and MySQL components in your Kubernetes cluster.

---

## 1. Inspect Nodes Before Tainting

Run the following command to check the current **labels** and **taints** on all nodes:

```bash
kubectl get nodes -o json | jq -r '
  .items[] |
  "NODE: \(.metadata.name)\nLABELS:" +
  ( .metadata.labels | to_entries | map("  \(.key)=\(.value)") | join("\n") ) +
  "\nTAINTS:" +
  ( if .spec.taints then (.spec.taints | map("  \(.key):\(.value // ""):\(.effect)") | join("\n")) else "  <none>" end ) +
  "\n----------------------------------------------------"
'
```

---

## 2. Add Taints to MySQL Nodes

Apply a **NoSchedule taint** to nodes labeled with `app=mysql`:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

---

## 3. Verify Taints Were Applied

Re-run the inspection command to confirm that the taints are now present:

```bash
kubectl get nodes -o json | jq -r '
  .items[] |
  "NODE: \(.metadata.name)\nLABELS:" +
  ( .metadata.labels | to_entries | map("  \(.key)=\(.value)") | join("\n") ) +
  "\nTAINTS:" +
  ( if .spec.taints then (.spec.taints | map("  \(.key):\(.value // ""):\(.effect)") | join("\n")) else "  <none>" end ) +
  "\n----------------------------------------------------"
'
```

---

## 4. Run the Bootstrap Script

Execute the provided script to deploy all resources into the cluster:

```bash
./bootstrap.sh
```

This script should apply all manifests, configure affinity and anti-affinity rules, and deploy both the **MySQL StatefulSet** and the **ToDo application Deployment**.

---

## 5. Validate Pods

Check that all pods are running in the correct namespaces and on the correct nodes:

For MySQL:

```bash
kubectl get pods -n mysql -o wide
```

For the ToDo app:

```bash
kubectl get pods -n todoapp -o wide
```

Ensure that:

* **MySQL pods** are scheduled only on nodes labeled `app=mysql` and respect taints/anti-affinity rules.
* **ToDo app pods** are scheduled on nodes labeled `app=todoapp` and follow the defined affinity/anti-affinity rules.
