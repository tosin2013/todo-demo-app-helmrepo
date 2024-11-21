#!/bin/bash 


cat >extra_vars.yaml<<EOF
ocp4_workload_gitea_operator_create_admin: true
ocp4_workload_gitea_operator_create_users: true
ocp4_workload_gitea_operator_migrate_repositories: true
ocp4_workload_gitea_operator_gitea_image_tag: 1.20.0
ocp4_workload_gitea_operator_repositories_list:
- repo: "https://github.com/tosin2013/todo-demo-app-helmrepo.git"
  name: "todo-demo-app-helmrepo"
  private: false
EOF

# testing
