# 1) How to validate the changes:

    kind cluster create --config cluster.yml

**Firstly check the labels and taints in nodes:**

    kubectl get nodes -o custom-columns=NAME:.metadata.name,LABELS:.metadata.labels,TAINTS:.spec.taints

**Then taint our nodes:**
    
    kubectl taint nodes kind-worker kind-worker2 app=mysql:NoSchedule
    
**Change our deployment.yml and statefulSet.yml manifests**

    kubectl apply -f deployment.yml
    kubectl apply -f statefulSet.yml

**Check MySQL(StatefulSet):**

    kubectl get pods -l app=mysql -o wide
    kubectl get nodes --show-labels

**Check ToDoApp(Depolyment):**

    kubectl get pods -l app=todoapp -o wide
    kubectl get pods -l app=todoapp -o wide