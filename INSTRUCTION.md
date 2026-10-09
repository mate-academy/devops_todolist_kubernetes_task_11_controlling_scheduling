# Deployment and Validation Instructions for Advanced Scheduling

## 1. Automated Deployment
Launch the setup using the complete automated deployment script from the root folder:
```bash
./bootstrap.sh
```

## 2. Infrastructure Validation

### Step 2.1: Verify Node Taints Management
Confirm that worker nodes matching the app=mysql specification received the scheduling block:
```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
```

### Step 2.2: Verify MySQL StatefulSet (mysql Namespace)
Verify database distribution across protected nodes:
```bash
kubectl get pods -n mysql -o wide
```

### Step 2.3: Verify ToDo Application Deployment (mateapp Namespace)
Verify application multi-pod high-availability layout:
```bash
kubectl get pods -n mateapp -l app=todolist -o wide
```
