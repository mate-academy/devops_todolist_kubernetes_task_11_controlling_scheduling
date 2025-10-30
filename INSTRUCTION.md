# Kubernetes Scheduling Control Instructions


## Initial setup — create kind cluster and run bootstrap

Before running the validation steps, create a local kind cluster with multiple worker nodes and run the repository bootstrap script:

1. Prereqs: Docker running, kind and kubectl installed. Quick checks:
```bash
docker --version
kind --version
kubectl version --client
```

2. Create a kind config (example with 2 workers). Save as kind-config.yaml:
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
    - role: control-plane
    - role: worker
    - role: worker
```

3. Create the cluster:
```bash
kind create cluster --name devops-task --config ./.infrastructure/cluster.yml
```

4. Ensure kubectl uses the new cluster:
```bash
kubectl cluster-info --context kind-devops-task
kubectl get nodes
```

5. Run the repository bootstrap script from the project root:
```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

6. Verify the bootstrap deployed resources:
```bash
kubectl get pods -A
```


## Prerequisites
- Kubernetes cluster with multiple worker nodes
- `kubectl` command-line tool
- Access to cluster with admin privileges

## Tasks

### 1. Node Inspection and Tainting
1. Inspect nodes and their labels:
```bash
kubectl get nodes --show-labels
```

2. Check existing taints on nodes:
```bash
kubectl describe nodes | grep Taint
```

3. Apply taint to nodes labeled with app=mysql:
```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

### 2. StatefulSet Configuration
Modify the StatefulSet YAML to include:

1. Toleration for mysql taint:
```yaml
tolerations:
- key: "app"
    operator: "Equal"
    value: "mysql"
    effect: "NoSchedule"
```

2. Pod Anti-Affinity rule to prevent MySQL pods on same node:
```yaml
affinity:
    podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
                matchExpressions:
                - key: app
                    operator: In
                    values:
                    - mysql
            topologyKey: "kubernetes.io/hostname"
```

3. Node Affinity rule for app=mysql labeled nodes:
```yaml
affinity:
    nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
                - key: app
                    operator: In
                    values:
                    - mysql
```

### 3. Deployment Configuration
Modify the Deployment YAML to include:

1. Node Affinity for app=todoapp labeled nodes:
```yaml
affinity:
    nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
            preference:
                matchExpressions:
                - key: app
                    operator: In
                    values:
                    - todoapp
```

2. Pod Anti-Affinity to prevent pods on same node:
```yaml
affinity:
    podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
                matchExpressions:
                - key: app
                    operator: In
                    values:
                    - todoapp
            topologyKey: "kubernetes.io/hostname"
```

## Validation

1. Verify node taints:
```bash
kubectl describe nodes | grep Taint
```

2. Check pod distribution:
```bash
kubectl get pods -o wide
```

3. Verify pod scheduling:
```bash
kubectl describe pod <pod-name>
```

Look for events section to ensure proper scheduling and no conflicts with affinity rules.