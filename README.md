# todo-demo-app-helmrepo

## Testing
```
oc login --token=CHANGEME --server=https://api.ocp4.examplpe.com:6443
cd charts
helm install  todo-demo-app-deployment  todo-demo-app/ --values todo-demo-app/values.yaml  --dry-run
```