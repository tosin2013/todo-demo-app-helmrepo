#!/bin/bash
set -x 

# This script prompts the user to enter a host and an agnosticd action.
# The user is asked to input the host address and the desired action to perform with agnosticd.
# The agnosticd action can be either 'create' or 'remove'.
read -p "Enter the host: " host
read -p "Enter the agnosticd action (create or remove): " agnosticd_action
# Prompt for OpenShift API details
read -p "Enter the OpenShift API Key: " OPENSHIFT_API_KEY
read -p "Enter the OpenShift API URL: " OPENSHIFT_API_URL

# This script checks the value of the 'agnosticd_action' variable.
# If the value is not 'create' or 'remove', it prints an error message
# and exits with a status code of 1.
if [[ "$agnosticd_action" != "create" && "$agnosticd_action" != "remove" ]]; then
  echo "Invalid agnosticd action. Please enter 'create' or 'remove'."
  exit 1
fi


# https://github.com/mikefarah/yq/releases
YQ_VERSION=4.44.3
if ! yq -v  &> /dev/null
then
    VERSION=v${YQ_VERSION}
    BINARY=yq_linux_amd64
    sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq
fi

# This script sets up the environment for deploying a workload using agnosticd.
# It defines the repository URL andhttps://api.cluster-pdcmf.pdcmf.sandbox1177.opentlc.com:6443 the specific workload to be used.
# If the GUID environment variable is not set, it prompts the user to enter the GUID.
# Variables:
#   agnosticd_repo: URL of the agnosticd repository.
#   agnosticd_workload: Name of the workload to be deployed.
#   GUID: Environment variable for the GUID (if not set, the user is prompted to enter it).
agnosticd_repo=https://github.com/tosin2013/agnosticd.git # https://github.com/redhat-cop/agnosticd
agnosticd_workload=ocp4_workload_argocd_quay_todo_app # ocp4_workload_gitea_operator
if [ -z "$GUID" ]; then
  read -p "Enter the GUID: " guid
else
  guid=$GUID
fi

# This script installs necessary packages and sets up the agnosticd repository.
# 
# It performs the following steps:
# 1. Installs required packages: wget, openssh-clients, sshpass, ansible-core, openssl, and python3-jmespath.
# 2. Checks if the agnosticd directory exists in the user's home directory:
#    - If it exists, it navigates to the directory, checks out the specified workload branch, and pulls the latest changes.
#    - If it does not exist, it clones the agnosticd repository and navigates to the newly created directory.
#
# Environment variables:
# - agnosticd_workload: The branch or workload to checkout in the agnosticd repository.
# - agnosticd_repo: The URL of the agnosticd repository to clone.
sudo dnf install wget openssh-clients sshpass ansible-core openssl python3-jmespath ansible-navigator  -y

if [ -d "$HOME/agnosticd" ]; then
  cd $HOME/agnosticd
  git checkout ${agnosticd_workload}
  git pull
else
  git clone $agnosticd_repo
  cd $HOME/agnosticd
fi

sudo cp /home/ec2-user/cluster-$GUID/auth/kubeconfig /home/${USER}
mkdir -p . /home/${USER}/.kube/
sudo chown ${USER}:users /home/${USER}/kubeconfig
export KUBECONFIG=/home/${USER}/kubeconfig


if ! oc whoami &> /dev/null; then
  echo "You are not logged into OpenShift. Please log in using 'oc login'."
  exit 1
fi

curl -L https://raw.githubusercontent.com/tosin2013/rhel9-bootstrap/refs/heads/main/agnosticd_templates/ocp-workloads/todo-demo-app-helmrepo.yaml -o ansible/configs/todo-demo-app-helmrepo.yaml
yq e '.cluster_one.api_key = "'${OPENSHIFT_API_KEY}'"' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?
yq e '.cluster_one.api_url = "'${OPENSHIFT_API_URL}'"' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?
yq e '.guid = "'${guid}'"' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?

ansible-navigator run ansible/main.yml \
          --eei quay.io/agnosticd/ee-multicloud:latest \
          --pass-environment-variable KUBECONFIG \
          -e @ansible/configs/todo-demo-app-helmrepo.yaml  -m stdout -vvv


ansible-navigator run ansible/destroy.yml \
      --eei quay.io/agnosticd/ee-multicloud:latest \
      -e @ansible/configs/todo-demo-app-helmrepo.yaml   -m stdout