# Deploying Todo App with OpenShift pipelines
Us this to quickly deploy app using tekton pipelines

**Test Configuration**
```bash
kustomize build openshift-pipelines
```

## Quick Start Script
**Deploying ArgoCD and Openshift Pipelines**
```bash
./quick-start.sh  argocd-quay-todo-demo-app-pipeline
```

### Configure Account on Gitea
`echo "USER ME: $(oc get route -A | grep gitea | awk '{print $3}')"`
![20230501131027](https://i.imgur.com/HmFsfVv.png)
**Migrate Repo**  
`https://github.com/tosin2013/todo-demo-app-helmrepo.git`
![20230501131113](https://i.imgur.com/Ck7D9Ab.png)
![20230501131223](https://i.imgur.com/TQBlAZK.png)
![20230501131338](https://i.imgur.com/gdti5iQ.png)

**Update App repo with new git url**
![20230501132221](https://i.imgur.com/b0nxu7X.png)

### Configure ArgoCD
```bash
nameSpace=openshift-gitops
argoRoute=$(oc get route openshift-gitops-server -n ${nameSpace} -o jsonpath='{.spec.host}')
argoUser=admin
argoPass=$(oc get secret/openshift-gitops-cluster -n ${nameSpace} -o jsonpath='{.data.admin\.password}' | base64 -d) 
echo "ArgoCD URL: https://${argoRoute}"
echo "ArgoCD User: ${argoUser}"
echo "ArgoCD Pass: ${argoPass}"
```
**Confirm `kustomizeBuildOptions: '--enable-helm'` is in ArgoCD Operator**
![20230501134442](https://i.imgur.com/g6GeDyl.png)
#### Got to Settings-> Repositories -> Connect Repo
**This could be automated in the future**
![20230501132745](https://i.imgur.com/mL6xDge.png)
**Skip SSL Verification**
![20230501132720](https://i.imgur.com/IJCA0Zc.png)
**Deploy pipeline**
```bash
BASE_URL=gitea-with-admin-gitea.apps.cluster-example.example.url.example.com
 oc create -f https://$BASE_URL/user1/todo-demo-app-helmrepo/raw/branch/main/app-config/cluster-config.yaml
```
![20230501134352](https://i.imgur.com/WfNZEx6.png)

### Configure Secrets
```bash 
./configure-pipeline-secrets.sh
```

### Populate Quay Secret
`echo "USER ME: $(oc get route -A | grep quay-registry-quay-quay-registry | awk '{print $3}')"`

**Create User**  
![20230501135137](https://i.imgur.com/uZfyUsP.png)

**Create todo-app organization**  
![20230501135248](https://i.imgur.com/gLwQXgw.png)

**Create todo-app repo**
![20230501135340](https://i.imgur.com/cN6L4BM.png)

**Get Secret**  
`username->Account Settings`
![20230501135519](https://i.imgur.com/drw7vSl.png)  

`Generate Encrypted Password`
![20230501135548](https://i.imgur.com/TlFSRww.png)  

`click on Kubernetes Secret ->View username-secret.yml`
![20230501135723](https://i.imgur.com/KRfylLk.png)  

`Copy secret into Openshift with the name container-registry-secret`
![20230501135827](https://i.imgur.com/UnxAx77.png)

## Deploy ArgoCD Pipeline 
![20230501140025](https://i.imgur.com/R2ExO1z.png)

## Start Pipeline
`echo "GIT_REPOSITORY: $(oc get route -A | grep quay-registry-quay-quay-registry | awk '{print $3}')/todo-app/todo-app"`
![20230501143544](https://i.imgur.com/oN769AD.png)
![20230501143624](https://i.imgur.com/UGKwjm1.png)

**Start Pipeline**

## Manual Steps
### Optional: Deploy Openshift Pipelines
```bash
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-pipelines-operator/overlays/latest
```

### Deploy App Remotely
```bash 
oc new-project todo-demo-app
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
```

## Configure Secrets

### Optional Argocd Configuration
```
kubectl apply -f https://api.hub.tekton.dev/v1/resource/tekton/task/argocd-task-connect-repo/0.1/raw
```

### Optional: Deploy Gitea
```bash
curl -OL https://raw.githubusercontent.com/tosin2013/openshift-demos/master/quick-scripts/deploy-gitea.sh
chmod +x deploy-gitea.sh
./deploy-gitea.sh
```

### Optional Deploy Quay 
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
![20230501111312](https://i.imgur.com/iKsTnjA.png)
```bash
oc new-project todo-demo-app
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
oc apply -k https://github.com/tosin2013/sno-quickstarts/gitops/cluster-config/openshift-gitops
oc create -f https://gitea-with-admin-gitea.apps.ocp4.example.com/user1/todo-demo-app-helmrepo/raw/branch/main/app-config/cluster-config.yaml
```