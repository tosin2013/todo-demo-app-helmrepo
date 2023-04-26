# Deploying Todo App with OpenShift pipelines
Us this to quickly deploy app using tekton pipelines

**Test Configuration**
```bash
kustomize build openshift-pipelines
```

**Deploy App Remotely**
```bash 
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
```
## Optional Argocd Configuration
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/argocd-task-connect-repo/0.1/raw
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