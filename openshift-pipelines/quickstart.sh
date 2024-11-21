#!/bin/bash

TAG=$1

usage() {
  echo "Usage: $0 <TAG>"
  echo "tags are: generic-quay-todo-demo-app-pipeline, build-and-push-to-quay-todo-demo-app, argocd-quay-todo-demo-app-pipeline"
  exit 1
}

if [[ $# -ne 1 ]]; then
  usage
fi

deploy_quay() {
  echo "Deploying Quay..."
  oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/quay-registry-operator/operator/overlays/stable-3.8 
  sleep 30s
  oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-data-foundation-operator/operator/overlays/stable-4.11 
  sleep 30s
  oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-container-storage-noobaa/overlays/default 
  sleep 120s
  oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/quay-registry-operator/instance/overlay/default
}

deploy_gitea() {
  echo "Deploying Gitea..."
  curl -OL https://raw.githubusercontent.com/tosin2013/openshift-demos/master/quick-scripts/deploy-gitea.sh
  chmod +x deploy-gitea.sh
  ./deploy-gitea.sh
}

deploy_app() {
  echo "Deploying Todo App..."
  oc new-project todo-demo-app
  #oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm 
  oc apply -k  https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
}

deploy_argocd() {
  echo "Deploying ArgoCD..."
  deploy_app
  oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-gitops
}

deploy_pipeline() {
  case "$1" in
    generic-quay-todo-demo-app-pipeline)
      echo "Deploying Generic Quay Todo Demo App Pipeline..."
      oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-pipelines-operator/overlays/latest
      deploy_app
      oc apply -f https://raw.githubusercontent.com/tosin2013/tekton-pipelines/main/generic-quay-todo-demo-app-pipeline.yaml
      ;;
    build-and-push-to-quay-todo-demo-app)
      echo "Deploying Build and Push To Quay Todo Demo App Pipeline..."
      deploy_app
      deploy_quay
      oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-pipelines-operator/overlays/latest
      oc apply -f https://raw.githubusercontent.com/tosin2013/tekton-pipelines/main/build-and-push-to-quay-todo-demo-app.yaml
      ;;
    argocd-quay-todo-demo-app-pipeline)
      echo "Deploying ArgoCD Quay Todo Demo App Pipeline..."
      deploy_argocd
      deploy_gitea
      deploy_quay
      oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-pipelines-operator/overlays/latest
      #oc apply -f https://raw.githubusercontent.com/tosin2013/todo-demo-app-helmrepo/main/openshift-pipelines/argocd-deploy-pipeline.yaml
      ;;
    *)
      echo "Invalid tag specified. Valid tags are: generic-quay-todo-demo-app-pipeline, build-and-push-to-quay-todo-demo-app, argocd-quay-todo-demo-app-pipeline"
      usage
      ;;
  esac
}

deploy_pipeline $TAG
