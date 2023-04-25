# NOT HELM CHART
Us this to quickly deploy app 

**Test App**
```bash
kustomize build not-helm
```

**Deploy App Remotely**
```bash 
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm
```