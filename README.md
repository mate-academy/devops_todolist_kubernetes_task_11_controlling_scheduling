# Deployment Guide
1. **Create cluster**
    ```sh
    kind create cluster --config cluster.yml
    ```

2. **Apply all manifests**
    ```sh
    ./bootstrap.sh
    ```

## Verification

1. **Check pods**
    ```sh
    kubectl get pods -n todoapp
    kubectl get pods -n mysql
    kubectl get pods -n ingress-nginx
    ```

2. **Check logs**
    ```sh
    kubectl logs <name_of_pod> -n <namespace>
    ```

3. **Check browser**
    ```sh
    http://localhost/
    ```

4. **Check labels**
    ```sh
    kubectl get nodes --show-labels
    ```

5. **Check working pods with mysql on kind-worker, kind-worker2 and todoapp any nodes except this two**
    ```sh
    kubectl get pods -o wide -n mysql
    kubectl get pods -o wide -n todoapp
    ```