## **Steps for validation**

### **1. Create a cluster using `kind`**  
Spin up the cluster using `kind` with the configuration file `cluster.yml`:

```bash
kind create cluster --config cluster.yml
```

---

### **2. Check that all nodes are available and properly labeled**  
Ensure that the nodes are created and have the correct labels:

```bash
kubectl get nodes --show-labels
```

Check for nodes with the following labels:
- `app=mysql`
- `app=todoapp`

---

### **3. Apply Taint to nodes for MySQL**  
Apply a Taint to nodes labeled with `app=mysql`:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

Verify that the Taint has been applied:

```bash
kubectl describe node <node-name>
```

---

### **4. Deploy resources to the cluster**  
Run the `bootstrap.sh` script, which will automatically create all the required resources (StatefulSet for MySQL and Deployment for the ToDo app):

```bash
bash bootstrap.sh
```

---

### **5. Validate the StatefulSet deployment for MySQL**  
Ensure that MySQL pods are only scheduled on nodes with the label `app=mysql`:

```bash
kubectl get pods -n mysql -o wide
```

- Confirm that the pods are located on nodes with the `app=mysql` label.  
- Ensure that pods are not scheduled on the same node due to the Pod Anti-Affinity rule.  
- Verify that the StatefulSet has been successfully deployed:

```bash
kubectl describe statefulset mysql -n mysql
```

---

### **6. Validate the Deployment for the ToDo app**  
Ensure that ToDo app pods are only scheduled on nodes with the label `app=todoapp`:

```bash
kubectl get pods -n todoapp -o wide
```

- Confirm that the pods are located on nodes with the `app=todoapp` label.  
- Ensure that pods are not scheduled on the same node due to the Pod Anti-Affinity rule.  
- Verify that the Deployment has been successfully deployed:

```bash
kubectl describe deployment todoapp -n todoapp
```

---

### **7. Check the application functionality**  
1. Retrieve the IP address of the pods or service for the ToDo app:

```bash
kubectl get svc -n todoapp
```

2. Open a web browser and navigate to the IP address and port to validate the application’s functionality.

---

### **Expected result:**  
- MySQL pods are scheduled on separate nodes with the `app=mysql` label.
- ToDo app pods are scheduled on separate nodes with the `app=todoapp` label.
- All services are running, and the ToDo app is accessible via the specified address.

---

### **Additional diagnostic commands**

1. **Check node labels**:

```bash
kubectl get nodes --show-labels
```

2. **Check pod status**:

```bash
kubectl get pods -A -o wide
```

3. **Check pod logs**:

```bash
kubectl logs <pod-name> -n todoapp
```