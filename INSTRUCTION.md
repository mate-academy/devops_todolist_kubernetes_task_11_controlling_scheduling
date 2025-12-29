
1. check current taints assigned.

kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"

2. check what nodes have "app=mysql" label.

kubectl get nodes --show-labels

3. assing "app=mysql:NoSchedule" taint to them.

kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule

4. ensure taint are updated.

kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"

5. run bootstrap.sh

6. check that mysql pods are running on kind-worker kind-worker2 only and not sharing nodes. same for todoapp pods.

kubectl get pods -n mysql -o wide
kubectl get pods -n todoapp -o wide