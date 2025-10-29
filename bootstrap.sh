#!/usr/bin/env bash
set -euo pipefail


kind create cluster --config ./.infrastructure/cluster.yml || true


kubectl apply -f ./.infrastructure/mysql/ns.yml
kubectl apply -f ./.infrastructure/app/ns.yml


kubectl label nodes kind-worker  app=mysql   --overwrite
kubectl label nodes kind-worker2 app=mysql   --overwrite
kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite
kubectl label nodes kind-worker3 app=todoapp --overwrite


kubectl apply -f ./.infrastructure/mysql/secret.yml
kubectl apply -f ./.infrastructure/mysql/configMap.yml
kubectl apply -f ./.infrastructure/mysql/service.yml
kubectl apply -f ./.infrastructure/mysql/statefulSet.yml
kubectl -n mysql rollout status sts/mysql --timeout=180s


kubectl apply -f ./.infrastructure/app/secret.yml
kubectl apply -f ./.infrastructure/app/deployment.yml
kubectl apply -f ./.infrastructure/app/service.yml
kubectl -n todo rollout status deploy/todo-app --timeout=180s


echo "[Nodes labels/taints]"
kubectl get nodes --show-labels | sed 's/,/\n    /g'
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" taints="}{.spec.taints}{"\n"}{end}'
echo "[MySQL pods]"
kubectl -n mysql get po -o wide
echo "[TODO pods]"
kubectl -n todo get po -o wide
