## Goal
This document explains how to validate that the cluster and manifests satisfy the task requirements:
- Nodes labeled `app=mysql` are tainted with `app=mysql:NoSchedule`.
- MySQL StatefulSet is able to schedule on tainted nodes (via tolerations).
- MySQL uses Pod anti-affinity to avoid scheduling multiple MySQL pods on the same node.
- MySQL uses Node affinity to schedule only on nodes labeled `app=mysql`.
- App Deployment uses Node affinity (PreferredDuringSchedulingIgnoredDuringExecution) to target nodes labeled `app=todoapp`.
- App Deployment uses Pod anti-affinity to avoid scheduling multiple app replicas on the same node.
- `bootstrap.sh` sets up the cluster and applies manifests.

> Run these checks after executing `./bootstrap.sh`.

---

## 0. Run bootstrap
```bash
chmod +x bootstrap.sh
./bootstrap.sh
Watch resources startup:

bash
Copy code
kubectl get pods -A --watch
Wait until pods are created (they may take some seconds).

1. Inspect nodes — labels and taints
List nodes with labels:

bash
Copy code
kubectl get nodes --show-labels
Check for nodes labeled app=mysql and app=todoapp. Example:

text
Copy code
kind-worker   Ready    <other>   app=mysql
Check taints on nodes:

bash
Copy code
kubectl describe node <node-name> | sed -n '/Taints:/,/Annotations:/p'
or

bash
Copy code
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
Expected: Nodes that have label app=mysql must have a taint app=mysql:NoSchedule.

2. Verify StatefulSet tolerations (MySQL)
Find the MySQL namespace and statefulset name (replace mysql-namespace if different):

bash
Copy code
kubectl get ns
kubectl get statefulsets -A
Inspect the StatefulSet YAML (look for tolerations):

bash
Copy code
kubectl get statefulset <statefulset-name> -n <mysql-namespace> -o yaml | sed -n '/tolerations:/,/affinity:/p'
Expected: The StatefulSet's pod template must include a tolerations entry that matches the node taint, e.g.:

yaml
Copy code
tolerations:
- key: "app"
  operator: "Equal"
  value: "mysql"
  effect: "NoSchedule"
This allows MySQL pods to be scheduled on nodes tainted app=mysql:NoSchedule.

3. Verify MySQL Node Affinity
Check nodeAffinity in the StatefulSet pod spec:

bash
Copy code
kubectl get statefulset <name> -n <mysql-namespace> -o yaml | sed -n '/nodeAffinity:/,/tolerations:/p'
Expected: There must be a nodeAffinity statement that targets nodes labeled app=mysql, either as requiredDuringSchedulingIgnoredDuringExecution (strict) or preferredDuringSchedulingIgnoredDuringExecution — task requires node affinity so mysql is scheduled on nodes with app=mysql label.

4. Verify MySQL Pod Anti-Affinity
In StatefulSet pod template check podAntiAffinity:

bash
Copy code
kubectl get statefulset <name> -n <mysql-namespace> -o yaml | sed -n '/podAntiAffinity:/,/nodeAffinity:/p'
Expected: A podAntiAffinity rule preventing MySQL pods from being co-located on the same node, e.g.:

yaml
Copy code
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: In
        values:
        - mysql
    topologyKey: "kubernetes.io/hostname"
5. Validate actual pod placement (MySQL)
List MySQL pods and which node they run on:

bash
Copy code
kubectl get pods -l app=mysql -n <mysql-namespace> -o wide
Expected: Each MySQL pod should be placed on a node labeled app=mysql. Additionally, there should not be two MySQL pods on the same node (if anti-affinity is required*).

To count MySQL pods per node:

bash
Copy code
kubectl get pods -l app=mysql -n <mysql-namespace> -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort | uniq -c
Expected: no node should show count > 1 (when required anti-affinity present).

6. Deployment (ToDo app) — Node Affinity (Preferred) and Pod Anti-Affinity
Inspect the Deployment YAML:

bash
Copy code
kubectl get deployment <deployment-name> -n <app-namespace> -o yaml
Look for:

spec.template.spec.affinity.nodeAffinity with preferredDuringSchedulingIgnoredDuringExecution that targets nodes with app=todoapp label.

spec.template.spec.affinity.podAntiAffinity preventing co-location of pods.

Example checks:

bash
Copy code
kubectl get deployment <name> -n <app-namespace> -o yaml | sed -n '/nodeAffinity:/,/podAntiAffinity:/p'
kubectl get deployment <name> -n <app-namespace> -o yaml | sed -n '/podAntiAffinity:/,/tolerations:/p'
Validate actual placement:

bash
Copy code
kubectl get pods -l app=todoapp -n <app-namespace> -o wide
kubectl get pods -l app=todoapp -n <app-namespace> -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort | uniq -c
Expected: Pods prefer nodes labeled app=todoapp (may be placed elsewhere if no matching nodes) and anti-affinity should try to spread them (if requiredDuringScheduling* is used then strictly one per node; if preferred* it may be best-effort).