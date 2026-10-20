1. Remove kind cluster if it exists:
`kind delete cluster --name kind`

2. Give execute permission for the file: 
`chmod 775 bootstrap.sh`

3. Create cluster first through script:
`./bootstrap.sh`

4. Check the nodes have been created: 
`kubectl get nodes --show-labels`
here will be:
- 2 nodes with mysql label
- 3 nodes with todoapp label
- 1 node with no label
    
5. Check taint nodes: 
`kubectl describe nodes | grep -E "^Name:|^Taints"`
here will be 2 nodes (kind-worker and kind-worker2):
*Taints: app=mysql:NoSchedule*
kind-control-plane has its own taint: node-role.kubernetes.io/control-plane
other worker nodes have no taints

6. Check where the pods are running
`kubectl get pods -A -o wide | grep -E "mysql|todoapp"`

Expected result (see the NODE column): 
- mysql pods (mysql-0, mysql-1): one on 'kind-worker', one on 'kind-worker2'
- 2 todoapp pods: on two different nodes from 'kind-worker3', 'kind-worker4', 'kind-worker5'
- no two pods of the same app share a node

7. Check that the taint really blocks pods without a toleration.

The test pod has no toleration and asks for a node with the `app=mysql`
label (`nodeSelector`), so the only nodes it could use are the tainted
ones.

```
kubectl apply -f .infrastructure/tests/taintTest.yml
```

Check the pod status:

```
kubectl get pod taint-test -o wide
```

Expected result: STATUS is `Pending`, NODE is `<none>`.

Check the reason:

```
kubectl describe pod taint-test | grep FailedScheduling
```

Expected result: the message contains `3 node(s) had untolerated taint
{app: mysql}`.
This proves that kind-worker and kind-worker3 reject pods without a
toleration.

Clean up the test pod:

```
kubectl delete pod taint-test
```

