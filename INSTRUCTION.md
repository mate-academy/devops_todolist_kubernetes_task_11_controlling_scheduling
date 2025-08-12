5. INSTRUCTION.md
markdown
Копировать
Редактировать
# Validation Instructions

## 1. Create the cluster
```bash
kind create cluster --config infrastructure/cluster.yml
2. Label and taint nodes
bash
Копировать
Редактировать
kubectl label nodes kind-worker app=mysql --overwrite
kubectl label nodes kind-worker2 app=todoapp --overwrite
kubectl taint nodes kind-worker app=mysql:NoSchedule --overwrite
3. Apply manifests
bash
Копировать
Редактировать
kubectl apply -f infrastructure/statefulset-mysql.yml
kubectl apply -f infrastructure/deployment-todoapp.yml
4. Validate node affinity and anti-affinity
MySQL pod:

bash
Копировать
Редактировать
kubectl get pods -l app=mysql -o wide
Should be scheduled on a node with app=mysql label.

ToDo App pods:

bash
Копировать
Редактировать
kubectl get pods -l app=todoapp -o wide
Should be scheduled on a node with app=todoapp label.

5. Check anti-affinity
Run:

bash
Копировать
Редактировать
kubectl get pods -o wide
Ensure that no two pods of the same app run on the same node.

yaml
Копировать
Редактировать

---
