# todo-demo-app-helmrepo workshop deployment instructions

## Pre-requisites
- [Red Hat OpenShift Container Platform Cluster (AWS)](https://catalog.demo.redhat.com/catalog?item=babylon-catalog-prod/sandboxes-gpte.ocp-wksp.prod&utm_source=webapp&utm_medium=share-link)
- OpenShift 4.17

## Configure workshop
SSH into bastion host
```bash
ssh lab-user@bastion.guid.example.opentlc.com
```

Login to OpenShift cluster as an adming
```bash
oc login --token=sha256~XXXXX --server=https://api.cluster-guid.guid.example.opentlc.com:6443
```

Run the AgnosticD deployment script
```bash
curl -OL https://raw.githubusercontent.com/tosin2013/todo-demo-app-helmrepo/refs/heads/main/agnosticd.sh
chmod +x agnosticd.sh
./agnosticd.sh
```