# Instructions for deploying the Todo application in a Kubernetes cluster using scheduler policies.

## Requirements: Docker Desktop

First, you need to create a cluster by running the following command:
```
kind create cluster --config cluster.yml --name <cluster-name>
```

To check nodes for tags and tints, use the following command:
```
kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels,TAINTS:.spec.taints
```

To identify nodes with the "mysql" tag, use the following command:
```
kubectl get nodes -l app=mysql
```

Add the "NoSchedule" taint to nodes labeled "app=mysql" (no node names needed):
```
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

To verify the taint:
```
kubectl get nodes -l app=mysql -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

To deploy all components, use the script in the project root:
```
bash bootstrap.sh
```

To check the labels on the nodes, use the following command:
```
kubectl get nodes --show-labels
```
2 nodes should be assigned to the app=mysql group, and 3 nodes to the app=todoapp group

If you check the detailed information about pods for the mysql and todoapp namespaces, the pod placement should correspond to the node labels:

```
kubectl get pods -n mysql -o wide
```

```
kubectl get pods -n todoapp -o wide
```
## Validate pod separation (anti-affinity)

MySQL pods must not share a node. The output of this command must be EMPTY (any line printed means two pods are on the same node):
```
kubectl get pods -n mysql -l app=mysql -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort | uniq -d
```

ToDo pods must not share a node. The output must also be EMPTY:
```
kubectl get pods -n todoapp -l app=todoapp -o jsonpath='{range .items[*]}{.spec.nodeName}{"\n"}{end}' | sort | uniq -d
```

MySQL pods must run only on nodes labeled app=mysql. Every node name from the first command must be in the list from the second:
```
kubectl get pods -n mysql -o wide
kubectl get nodes -l app=mysql
```

Check that the anti-affinity rule is present in the Deployment:
```
kubectl get deployment todoapp -n todoapp -o jsonpath='{.spec.template.spec.affinity.podAntiAffinity}'
```

## After running the checks, you can delete the cluster using the following command:
```
kind delete cluster --name <cluster-name>
```