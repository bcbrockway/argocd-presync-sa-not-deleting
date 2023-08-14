#!/bin/bash

set -o pipefail

k3d cluster create argocd-bug --agents 2 --wait
kubectl create ns argocd
kubectl apply -f install.yaml -n argocd

echo "waiting for argocd-server to be ready..."
while ! kubectl wait --for=condition=Ready --timeout=300s -n argocd pod -l app.kubernetes.io/name=argocd-server; do
  sleep 2
done

kubectl port-forward -n argocd "$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -oname)" 8080 >/dev/null &

echo "ArgoCD UI: http://localhost:8080"
echo "Admin password: $(kubectl get secret -n argocd argocd-initial-admin-secret -ojson | jq -r '.data.password' | base64 -d)"
