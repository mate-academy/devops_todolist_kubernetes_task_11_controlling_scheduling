## Before validation, create cluster and apply all infrastructure manifests:
```shell
    ./bootstrap.sh
```

## Validate that pods running correctly:
- ```kubectl get pods -n mysql -o wide```  - you should see that all mysql pods running only on mysql nodes
- ```kubectl get pods -n todoapp -o wide```  - you should see that all todoapp pods running only on todoapp nodes
