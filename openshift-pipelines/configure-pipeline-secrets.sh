#!/bin/bash
set -xe 
# Define the namespace, secret name, and config map name
NAMESPACE="todo-demo-app"
SECRET_NAME="argocd-env-secret"
DOCKER_REGISTRY_SECRET_NAME="container-registry-secret"
CONFIG_MAP_NAME="argocd-env-configmap"


nameSpace=openshift-gitops
SERVER=$(oc get route openshift-gitops-server -n ${nameSpace} -o jsonpath='{.spec.host}')
USERNAME=admin
PASSWORD=$(oc get secret/openshift-gitops-cluster -n ${nameSpace} -o jsonpath='{.data.admin\.password}' | base64 -d) 

# Check if any of the inputs are empty 
if [[ -z "${SERVER}" || -z "${USERNAME}" || -z "${PASSWORD}" ]]; then
  echo "All inputs are required."
  exit 1
fi

# Encode the username and password as base64
USERNAME_BASE64=$(echo -n "${USERNAME}" | base64)
PASSWORD_BASE64=$(echo -n "${PASSWORD}" | base64)

# Create the ArgoCD secret
kubectl create secret generic "${SECRET_NAME}" \
  --namespace="${NAMESPACE}" \
  --from-literal="ARGOCD_USERNAME=$(echo ${USERNAME_BASE64} | base64 --decode)" \
  --from-literal="ARGOCD_PASSWORD=$(echo ${PASSWORD_BASE64} | base64 --decode)"

oc adm policy add-scc-to-user privileged -z pipeline -n  todo-demo-app
oc adm policy add-role-to-user admin system:serviceaccount:todo-demo-app:pipeline -n  todo-demo-app
oc policy add-role-to-group system:image-puller system:serviceaccounts:todo-demo-app -n todo-demo-app
# Create the ArgoCD config map
kubectl create configmap "${CONFIG_MAP_NAME}" \
  --namespace="${NAMESPACE}" \
  --from-literal="ARGOCD_SERVER=${SERVER}:443"
