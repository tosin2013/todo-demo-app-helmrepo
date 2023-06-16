#!/bin/bash 


cat >extra_vars.yaml<<EOF
ocp4_workload_gitea_operator_create_admin: true
ocp4_workload_gitea_operator_create_users: true
ocp4_workload_gitea_operator_migrate_repositories: true
ocp4_workload_gitea_operator_gitea_image_tag: 1.19.3
ocp4_workload_gitea_operator_repositories_list:
- repo: "https://github.com/tosin2013/rhacm-configuration"
  name: "rhacm-configuration"
  private: false
- repo: "https://github.com/tosin2013/applications"
  name: "applications"
  private: false
EOF
