# Інструкція з перевірки виконання Task 11: Controlling Scheduling

Цей документ містить опис кроків для перевірки коректності налаштування правил Affinity, Taints та Tolerations у кластері Kubernetes.

## 1. Попередня підготовка нод (Labels & Taints)

Для того, щоб правила планування спрацювали, ноди кластера були підготовлені наступним чином:

### Маркування нод (Labels):
Ми розділяємо ноди для бази даних та для основного додатка:
- **Воркери для MySQL (1-2):**
  `kubectl label nodes kind-worker kind-worker2 app=mysql`
- **Воркери для Todoapp (3-5):**
  `kubectl label nodes kind-worker3 kind-worker4 kind-worker5 app=todoapp`

### Накладання обмежень (Taints):
Щоб запобігти випадковому розгортанню інших подів на ноди з базою даних, накладено `Taint`:
`kubectl taint nodes -l app=mysql app=mysql:NoSchedule`

---

## 2. Перевірка розгортання MySQL (StatefulSet)

### Вимоги:
- База має працювати на "заплямованих" (tainted) нодах.
- Два поди MySQL не повинні знаходитися на одній ноді (Anti-Affinity).
- База має віддавати перевагу нодам з лейблом `app=mysql`.

### Як перевірити:
Виконайте команду:
```bash
kubectl get pods -n mysql -o wide -l app=mysql