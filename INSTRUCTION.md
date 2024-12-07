# HOW TO VALIDATE SOLUTION

1. All manifests were successfully applied to the cluster
2. To validate that taints ware applied to the nodes, run the following command:
    ```bash
    kubectl get nodes -o json | jq '.items[] | {name:.metadata.name, taints:.spec.taints}'
    ```
    We get the following output:
    ```
   {
      "name":"kind-control-plane",
      "taints":[
         {
            "effect":"NoSchedule",
            "key":"node-role.kubernetes.io/control-plane"
         }
      ]
   }
   {
      "name":"kind-worker",
      "taints":[
         {
            "effect":"NoSchedule",
            "key":"app",
            "value":"mysql"
         }
      ]
   }
   {
      "name":"kind-worker2",
      "taints":[
         {
            "effect":"NoSchedule",
            "key":"app",
            "value":"mysql"
         }
      ]
   }
   {
      "name":"kind-worker3",
      "taints":null
   }
   {
      "name":"kind-worker4",
      "taints":null
   }
   {
      "name":"kind-worker5",
      "taints":null
   }
   {
      "name":"kind-worker6",
      "taints":null
   }
    ```

3. To validate that pods were created in proper nodes, run the following commands:
    ```bash
    kubectl get pods -o wide -n mysql
    ```
    We get the following output:
    ```
    NAME      READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    mysql-0   1/1     Running   0          19m   10.244.6.3   kind-worker    <none>           <none>
    mysql-1   1/1     Running   0          16m   10.244.4.3   kind-worker2   <none>           <none>
    ```

    ```bash
    kubectl get pods -o wide -n todoapp
    ```
   
    We get the following output:
    ```
    NAME                      READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
    todoapp-7ddfbbfbc-479nn   1/1     Running   0          19m   10.244.5.2   kind-worker4   <none>           <none>
    todoapp-7ddfbbfbc-v8h4q   1/1     Running   0          19m   10.244.2.2   kind-worker3   <none>           <none>
    ```
