#!/bin/bash

echo "=== Создание kind кластера ==="
kind create cluster --config=cluster.yml

echo "=== Ожидание готовности кластера ==="
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "=== Проверка нод и их лейблов ==="
kubectl get nodes --show-labels

echo "=== Добавление taint на ноды с app=mysql ==="
# Получаем имена нод с лейблом app=mysql и добавляем taint
kubectl get nodes -l app=mysql -o jsonpath='{.items[*].metadata.name}' | xargs -I {} kubectl taint node {} app=mysql:NoSchedule

echo "=== Проверка taint ==="
kubectl describe nodes | grep -A 5 -B 5 Taints

echo "=== Сборка Docker образа для ToDo приложения ==="
cd src
docker build -t todoapp:latest .
cd ..

echo "=== Загрузка образа в kind кластер ==="
kind load docker-image todoapp:latest

echo "=== Развертывание MySQL StatefulSet ==="
kubectl apply -f mysql-statefulset.yaml

echo "=== Ожидание готовности MySQL ==="
kubectl wait --for=condition=Ready pod -l app=mysql --timeout=300s

echo "=== Развертывание ToDo приложения ==="
kubectl apply -f todoapp-deployment.yaml

echo "=== Ожидание готовности ToDo приложения ==="
kubectl wait --for=condition=Ready pod -l app=todoapp --timeout=300s

echo "=== Проверка размещения подов ==="
echo "MySQL поды:"
kubectl get pods -l app=mysql -o wide

echo "ToDo поды:"
kubectl get pods -l app=todoapp -o wide

echo "=== Проверка сервисов ==="
kubectl get services

echo "=== Готово! Приложение доступно на http://localhost:30007 ==="