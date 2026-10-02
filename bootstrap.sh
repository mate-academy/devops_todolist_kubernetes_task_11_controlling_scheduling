#!/bin/bash
set -e

kubectl taint nodes -l app=mysql app=mysql:NoSchedule --overwrite

kubectl apply -f .infrastructure/mysql/ns.yml
kubectl apply -f .infrastructure/mysql/configMap.yml
kubectl apply -f .infrastructure/mysql/secret.yml
kubectl apply -f .infrastructure/mysql/service.yml
kubectl apply -f .infrastructure/mysql/statefulSet.yml

kubectl apply -f .infrastructure/app/ns.yml
kubectl apply -f .infrastructure/app/pv.yml
kubectl apply -f .infrastructure/app/pvc.yml
kubectl apply -f .infrastructure/app/secret.yml
kubectl apply -f .infrastructure/app/configMap.yml
kubectl apply -f .infrastructure/app/clusterIp.yml
kubectl apply -f .infrastructure/app/nodeport.yml
kubectl apply -f .infrastructure/app/hpa.yml
kubectl apply -f .infrastructure/app/deployment.yml

# Install Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Run the controller on the Node whose ports 80 and 443 are exposed to localhost
kubectl patch deployment ingress-nginx-controller \
  --namespace ingress-nginx \
  --type merge \
  --patch '{"spec":{"template":{"spec":{"nodeSelector":{"kubernetes.io/os":"linux","ingress-ready":"true"}}}}}'

# Wait until the controller rollout is complete
kubectl rollout status \
  deployment/ingress-nginx-controller \
  --namespace ingress-nginx \
  --timeout=180s

# The admission jobs can disappear immediately after completion. Verify the
# webhook itself with a bounded server-side dry-run before creating the Ingress.
for attempt in {1..30}; do
  if kubectl apply --dry-run=server \
    -f .infrastructure/ingress/ingress.yml >/dev/null 2>&1; then
    break
  fi

  if [ "$attempt" -eq 30 ]; then
    echo "Ingress admission webhook did not become ready" >&2
    exit 1
  fi

  sleep 2
done

kubectl apply -f .infrastructure/ingress/ingress.yml
