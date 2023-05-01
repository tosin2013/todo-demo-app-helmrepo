# Deploying Todo App with OpenShift pipelines
Us this to quickly deploy app using tekton pipelines

**Test Configuration**
```bash
kustomize build openshift-pipelines
```

## Optional: Deploy Openshift Pipelines
```bash
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-pipelines-operator/overlays/latest
```

## Deploy App Remotely
```bash 
oc new-project todo-demo-app
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
```

## Optional Argocd Configuration
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/argocd-task-connect-repo/0.1/raw
```

## Optional: Deploy Gitea
```bash
curl -OL https://raw.githubusercontent.com/tosin2013/openshift-demos/master/quick-scripts/deploy-gitea.sh
chmod +x deploy-gitea.sh
./deploy-gitea.sh
```

## Optional Deploy Quay 
```bash
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/quay-registry-operator/operator/overlays/stable-3.8
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-data-foundation-operator/operator/overlays/stable-4.11
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-container-storage-noobaa/overlays/default
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/quay-registry-operator/instance/overlay/default
```
### generic-quay-todo-demo-app-pipeline
![20230426080630](https://i.imgur.com/hUkCNCB.png)

### build-and-push-to-quay-todo-demo-app
```bash
oc new-project todo-demo-app
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
```


### argocd-quay-todo-demo-app-pipeline
```bash
oc new-project todo-demo-app
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-gitops
```