# NOT HELM CHART
Us this to quickly deploy app 

**Test Configuration**
```bash
kustomize build openshift-pipelines
```

**Deploy App Remotely**
```bash 
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
```