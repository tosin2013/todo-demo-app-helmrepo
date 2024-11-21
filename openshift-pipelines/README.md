# Deploying Todo App with OpenShift pipelines

Follow these steps to fully deploy an app using Tekton Pipelines, ArgoCD, Quay, and Gitea

> Please note that you will need admin access to your OpenShift cluster and should be running OpenShift version 4.11 or 4.12

**Pre-test Configuration**

After you `git clone` this directory, run the following to ensure the manifests will build correctly.

```bash
kustomize build openshift-pipelines
```

## Deploy Using Github Actions
[Deploy using Github Actions](github-actions.md)

## Quick Start Guide

**When in doubt, run this script!**
You may need to run this script several times over a period of minutes to ensure everything is built.

**Deploying ArgoCD and Openshift Pipelines**
```bash
cd ./openshift-pipelines
./quickstart.sh  argocd-quay-todo-demo-app-pipeline
```

### Configure Account on Gitea

Run the following command to get the route to your Gitea instance. Navigate there and enter in credentials like below. Choose whatever password you want.

`echo "USER ME: $(oc get route -A | grep gitea | awk '{print $3}')"`

![20230501131027](https://i.imgur.com/HmFsfVv.png)

**Migrate Repo**
Migrate this repo to Gitea: `https://github.com/tosin2013/todo-demo-app-helmrepo.git`

![20230501131113](https://i.imgur.com/Ck7D9Ab.png)

![20230501131223](https://i.imgur.com/TQBlAZK.png)

![20230501131338](https://i.imgur.com/gdti5iQ.png)

**Update App repo with new Git URL**

![20230501132221](https://i.imgur.com/b0nxu7X.png)

### Configure ArgoCD

**Confirm `kustomizeBuildOptions: '--enable-helm'` is in the ArgoCD Operator YAML.** Make sure you are in the `openshift-gitops` project.

![20230501134442](https://i.imgur.com/g6GeDyl.png)

Back in the terminal enter the following to get your ArgoCD credentials. Navigate to the ArgoCD URL

```bash
nameSpace=openshift-gitops
argoRoute=$(oc get route openshift-gitops-server -n ${nameSpace} -o jsonpath='{.spec.host}')
argoUser=admin
argoPass=$(oc get secret/openshift-gitops-cluster -n ${nameSpace} -o jsonpath='{.data.admin\.password}' | base64 -d) 
echo "ArgoCD URL: https://${argoRoute}"
echo "ArgoCD User: ${argoUser}"
echo "ArgoCD Pass: ${argoPass}"
```

#### Got to Settings-> Repositories -> Connect Repo

**Make sure to check "Skip SSL Verification"**

![20230501132745](https://i.imgur.com/mL6xDge.png)

![20230501132720](https://i.imgur.com/IJCA0Zc.png)

**Deploy pipeline**

> If this step fails, you may need to delete the ArgoCD resource and recreate it.

```bash
BASE_URL=gitea-with-admin-gitea.apps.cluster-example.example.url.example.com
 oc create -f https://$BASE_URL/user1/todo-demo-app-helmrepo/raw/branch/main/app-config/cluster-config.yaml
```

![20230501134352](https://i.imgur.com/WfNZEx6.png)

### Configure Secrets

This will automatically create the needed secrets

```bash 
sh ./configure-pipeline-secrets.sh
```

### Populate Quay Secret

Now get the Quay image registry route and navigate there

`echo "USER ME: $(oc get route -A | grep quay-registry-quay-quay-registry | awk '{print $3}')"`

**Create Quay User**

![20230501135137](https://i.imgur.com/uZfyUsP.png)

**Create todo-app organization**

![20230501135248](https://i.imgur.com/gLwQXgw.png)

**Create todo-app repo**

> Make sure to set this repo to "Public"

![20230501135340](https://i.imgur.com/cN6L4BM.png)

**Get Quay Account Secret**

`username -> Account Settings`

![20230501135519](https://i.imgur.com/drw7vSl.png)  

`Generate Encrypted Password`

![20230501135548](https://i.imgur.com/TlFSRww.png)  

`Click on Kubernetes Secret -> View username-secret.yml`

![20230501135723](https://i.imgur.com/KRfylLk.png)  

`Copy secret into OpenShift with the name container-registry-secret`

> Use the + icon in the top right corner of the OpenShift console to quickly add YAML. Make sure you are in the todo-demo-app!

![20230501135827](https://i.imgur.com/UnxAx77.png)

## Deploy ArgoCD Pipeline

![20230501140025](https://i.imgur.com/R2ExO1z.png)

## Start Pipeline
Start the `argocd-quay-todo-demo-app-pipeline` pipeline and replace the values as shown.

`echo "GIT_REPOSITORY: $(oc get route -A | grep quay-registry-quay-quay-registry | awk '{print $3}')/todo-app/todo-app"`

![20230501143544](https://i.imgur.com/oN769AD.png)

![20230501143624](https://i.imgur.com/UGKwjm1.png)

![20230501150240](https://i.imgur.com/LhPJc0D.png)

**Congratulations! You now have all the parts of a modern working developer workflow.**

## Manual Steps

If the Quick Start Guide above does not work for you or if you want to try the manual steps for whatever reason, read on.

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
