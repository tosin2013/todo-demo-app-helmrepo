# Deploying Todo App with OpenShift pipelines
Us this to quickly deploy app using tekton pipelines
![20230425175634](https://i.imgur.com/VvpIfT8.png)
**Test Configuration**
```bash
kustomize build openshift-pipelines
```

**Deploy App Remotely**
```bash 
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/not-helm
oc apply -k https://github.com/tosin2013/todo-demo-app-helmrepo/openshift-pipelines
```