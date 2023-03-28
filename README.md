# todo-demo-app-helmrepo

## Requirements
**Install Helm**
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

## YAML Testing
```
git clone https://github.com/tosin2013/todo-demo-app-helmrepo.git
cd todo-demo-app-helmrepo/
oc login --token=CHANGEME --server=https://api.ocp4.example.com:6443
cd charts
helm install  todo-demo-app-deployment  todo-demo-app/ --values todo-demo-app/values.yaml  --dry-run
```

## Deployment Testing
```
 oc new-project todo-demo-app
 helm install  todo-demo-app-deployment  todo-demo-app/ --values todo-demo-app/values.yaml 
 ```

## Uninstall
```
helm uninstall todo-demo-app-deployment
```
