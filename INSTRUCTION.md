## Instruction on how to validate the changes 
1. Checking Taints on nodes:
```bash
kubectl describe nodes -l app=mysql | grep Taints
```
2. Checking Node Afinity Pods allocation:
```bash
kubectl get pods -o wide
```
3. Check the labels on nodes:
```bash
kubectl get nodes --show-labels
```
4. Check specific resources:
```bash
kubectl get statefulset mysql -o yaml
kubectl get deployment todoapp -o yaml
```
5. Verify the YAML files have the right configs — e.g., check that StatefulSet has:
- tolerations
- nodeAffinity for app=mysql
- podAntiAffinity

6. Verify pods are on different nodes — your current command shows this,
but you could make it clearer