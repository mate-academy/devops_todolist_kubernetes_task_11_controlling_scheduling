To validate changes use command:

    kind create cluster --config cluster.yml

To see nodes labels use command:

    kubectl get nodes --show-labels

To taint mysql nodes use command:

    kubectl taint nodes <mysql-nodes> aapp=mysql:NoSchedule

To see whch pod uses which node use command:

    kubectl get pods -n todoapp -o wide 

    kubectl get pods -n mysql -o wide 
    
    kubectl get nodes -o wide 