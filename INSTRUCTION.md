1. Start the Kind cluster::
```bash
kind create cluster --config cluster.yml
```
2. Add labels and taints to the nodes:
```bash
kubectl label nodes mysql-node app=mysql
kubectl taint nodes mysql-node app=mysql:NoSchedule
kubectl label nodes todoapp-node app=todoapp
```

3. Deploy the StatefulSet and Deployment:
```bash
kubectl apply -f .infrastructure/mysql/statefulSet.yml
kubectl apply -f .infrastructure/app/deployment.yml
```

4. Check the pods:
```bash
kubectl get pods -n mysql
kubectl get pods -n todoapp
```

5. Check the nodes where the pods are running:
```bash
kubectl describe pod mysql -n mysql
kubectl describe pod todoapp -n todoapp
```

6. Ensure the pods are correctly distributed according to the affinity/anti-affinity rules.







