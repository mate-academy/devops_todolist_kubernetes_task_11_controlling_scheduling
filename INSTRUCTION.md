# Instructions for deploying the Todo application in a Kubernetes cluster using scheduler policies.

## Requirements: Docker Ddesctop

First, you need to create a cluster by running the following command:
```
kind create cluster --config cluster.yml --name <cluster-name>
```

To check nodes for tags and tints, use the following command:
```
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"
```

To identify nodes with the "mysql" tag, use the following command:
```
kubectl get nodes -l app=mysql
```

Add the "NoSchedule" tag to nodes labeled "mysql"
```
kubectl taint nodes <cluster-name>-worker<#..> <cluster-name>-worker<#..> app=mysql:NoSchedule
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

## After running the checks, you can delete the cluster using the following command:
```
kind delete cluster --name <cluster-name>
```