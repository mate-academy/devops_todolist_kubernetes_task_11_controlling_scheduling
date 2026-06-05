# 1) How to validate the changes:

**Check MySQL(StatefulSet):**

    kubectl get pods -l app=mysql -o wide
    kubectl get nodes --show-labels

**Check ToDoApp(Depolyment):**

    kubectl get pods -l app=todoapp -o wide
    kubectl get pods -l app=todoapp -o wide