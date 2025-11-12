# Запусти скрипт bootstrap для створення namespace і розгортання додатків:
chmod +x bootstrap.sh
./bootstrap.sh

# Перевір, що StatefulSet mysql розгорнувся:
kubectl get pods -n mysql
# Всі поди повинні бути в статусі Running.

# Перевір, що Deployment todoapp розгорнувся:
kubectl get pods -n todoapp
# Поди також мають бути у статусі Running.

# Перевірка роботи додатка
# Знайди IP або налаштуй порт-форвардинг:
kubectl port-forward deployment/todoapp 8080:8080 -n todoapp

# Потім у браузері або через curl відкрий:
http://localhost:8080/api/

# Для перевірки MySQL можна підключитися до пода:
kubectl exec -it -n mysql $(kubectl get pods -n mysql -o name | head -n1) -- mysql -u root -p

# Перевірка правил scheduling (optional)
# Перевір Node Labels:
kubectl get nodes --show-labels

# Перевір Taints:
kubectl get nodes -o jsonpath="{range .items[*]}{.metadata.name} {.spec.taints[]}{\"\n\"}"

# Перевір Affinity та Tolerations:
kubectl describe pod -n mysql <pod-name>
kubectl describe pod -n todoapp <pod-name>
