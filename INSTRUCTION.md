How to validate the changes:

1. To ensure MySQL StatefulSet and ToDo app Deployment are deployed in the cluster:
    - kubectl apply -f .infrastructure/mysql 
    - kubectl apply -f .infrastructure/app
2. To verify that MySQL pods are scheduled on nodes labeled app=mysql:
    - kubectl get pods -n mysql -o wide 
3. To verify that ToDo app pods are scheduled on nodes labeled app=todoapp:
    - kubectl get pods -n todoapp -o wide
