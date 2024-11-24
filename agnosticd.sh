#!/bin/bash
set -x 

# This script prompts the user to enter a host and an agnosticd action.
# The user is asked to input the host address and the desired action to perform with agnosticd.
# The agnosticd action can be either 'create' or 'remove'.
read -p "Enter the host: " host
read -p "Enter the agnosticd action (create or remove): " agnosticd_action
# This script checks the value of the 'agnosticd_action' variable.
# If the value is not 'create' or 'remove', it prints an error message
# and exits with a status code of 1.
if [[ "$agnosticd_action" != "create" && "$agnosticd_action" != "remove" ]]; then
  echo "Invalid agnosticd action. Please enter 'create' or 'remove'."
  exit 1
fi

# Prompt for OpenShift API details
read -p "Enter the OpenShift API Key: " OPENSHIFT_API_KEY
read -p "Enter the OpenShift API URL: " OPENSHIFT_API_URL


# Prompt user for the number of users
read -p "Enter the number of users to add: " user_count

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
  cd $HOME
  git clone $agnosticd_repo
  cd $HOME/agnosticd
  git checkout ${agnosticd_workload}
fi

# 1. Copies the kubeconfig file from the specified source directory to the home directory of the current user.
# 2. Creates the .kube directory in the user's home directory if it does not already exist.
# 3. Changes the ownership of the copied kubeconfig file to the current user and the 'users' group.
# 4. Sets the KUBECONFIG environment variable to point to the copied kubeconfig file.
sudo cp /home/ec2-user/cluster-$GUID/auth/kubeconfig /home/${USER}
mkdir -p . /home/${USER}/.kube/
sudo chown ${USER}:users /home/${USER}/kubeconfig
export KUBECONFIG=/home/${USER}/kubeconfig


# This script checks if the user is logged into OpenShift.
# If the user is not logged in, it prints a message instructing the user to log in using 'oc login'
# and exits with a status code of 1.
if ! oc whoami &> /dev/null; then
  echo "You are not logged into OpenShift. Please log in using 'oc login'."
  exit 1
fi

# This script performs the following actions:
# 1. Downloads the todo-demo-app-helmrepo.yaml file from the specified GitHub repository URL and saves it to ansible/configs directory.
# 2. Updates the 'cluster_one.api_key' field in the downloaded YAML file with the value of the OPENSHIFT_API_KEY environment variable.
# 3. Updates the 'cluster_one.api_url' field in the downloaded YAML file with the value of the OPENSHIFT_API_URL environment variable.
# 4. Updates the 'guid' field in the downloaded YAML file with the value of the guid environment variable.
# If any of the yq commands fail, the script exits with the corresponding error code.
curl -L https://raw.githubusercontent.com/tosin2013/rhel9-bootstrap/refs/heads/main/agnosticd_templates/ocp-workloads/todo-demo-app-helmrepo.yaml -o ansible/configs/todo-demo-app-helmrepo.yaml
yq e '.cluster_one.api_key = "'${OPENSHIFT_API_KEY}'"' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?
yq e '.cluster_one.api_url = "'${OPENSHIFT_API_URL}'"' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?
yq e '.guid = "'${guid}'"' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?


# Validate input
# This script checks if the variable 'user_count' contains a valid number.
# If 'user_count' does not match a regular expression for one or more digits,
# it prints an error message and exits with status code 1.
if ! [[ "$user_count" =~ ^[0-9]+$ ]]; then
  echo "Error: Please enter a valid number."
  exit 1
fi

# Create users array dynamically
# This script generates a comma-separated list of user names in the format "user1", "user2", ..., "userN".
# The variable `user_count` should be set to the number of users to include in the list.
# The resulting list is stored in the `users_list` variable.
users_list=""
for i in $(seq 1 $user_count); do
  users_list+="\"user$i\", "
done

# This script snippet removes the trailing comma and space from the variable 'users_list'.
# It uses parameter expansion to strip the last comma and space from the string.
# Remove the trailing comma and space
users_list=${users_list%, }

# This script updates a YAML file with a new list of users.
# It uses the 'yq' command to edit the 'users' field in the specified YAML file.
# The 'users_list' variable contains the new list of users to be added.
# The '-i' option is used to edit the file in place.
# If the 'yq' command fails, the script exits with the corresponding error code.
# Update the YAML file with the new users
yq e '.users = ['"${users_list}"']' -i "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml" || exit $?

# This script displays the contents of the updated YAML file located at
# /home/<username>/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml.
# It uses the `cat` command to output the file's content to the terminal.
# Note: <username> is dynamically replaced with the current user's username.
# Display the updated YAML file
cat "/home/${USER}/agnosticd/ansible/configs/todo-demo-app-helmrepo.yaml"

# This script runs the appropriate Ansible playbook based on the value of the
# environment variable `agnosticd_action`. If `agnosticd_action` is set to "create",
# it runs the `ansible/main.yml` playbook using the specified execution environment
# image and passes the `KUBECONFIG` environment variable. It also uses the configuration
# file `ansible/configs/todo-demo-app-helmrepo.yaml` and outputs in stdout mode.
# If `agnosticd_action` is set to "destroy", it runs the `ansible/destroy.yml` playbook
# using the same execution environment image and configuration file, and outputs in stdout mode.
# Run the appropriate Ansible playbook based on the action
if [ "$agnosticd_action" == "create" ]; then
  ansible-navigator run ansible/main.yml \
            --eei quay.io/agnosticd/ee-multicloud:latest \
            --pass-environment-variable KUBECONFIG \
            -e @ansible/configs/todo-demo-app-helmrepo.yaml -m stdout -v
elif [ "$agnosticd_action" == "destroy" ]; then
  ansible-navigator run ansible/destroy.yml \
            --eei quay.io/agnosticd/ee-multicloud:latest \
            -e @ansible/configs/todo-demo-app-helmrepo.yaml -m stdout
fi
