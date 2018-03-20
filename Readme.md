The project provides Terraform scripts to automate the provisioning of a kubernetes cluster on Openstack IaaS.
Using these scripts for production grade deployments isn't recommended as it doesn't support multi master HA.


You can quickly provision a cluster following these steps:

2. Install terraform >0.11 on your local Linux env
2. Git clone the repo
2. Download your openstack provider RC file and source it. It precises the `OS_USERNAME` and `OS_PASSWORD` env variables. You can alternatively manually export them
6. Create a directory for each required environment in <PROJECT_ROOT>/env/<CLUSTER_NAME> and copy the tfvars file in it from <PROJECT_ROOT>/env/example.
6. Modify the terraform.tfvars to match your Openstack cloud provider variables and project common variables if you don't want to use defaults.
External public access is possible with a dynamic DNS, precise it before building the cluster to put the DNS name in certificates.
The Kubernetes token can be generated with

  `go run tokens.go`

7. Initiate Terraform to download the required Terraform modules with

  `INSTANCE=<CLUSTER_NAME> make init` 

8. Get Terraform with

  `INSTANCE=<CLUSTER_NAME> make get` 

9. Build the cluster with

  `TF_VAR_openstack_username=$OS_USERNAME \`

  `TF_VAR_openstack_password=$OS_PASSWORD \`

  `TF_VAR_openstack_auth_url=$OS_AUTH_URL \`

  `TF_VAR_openstack_tenant_id=$OS_PROJECT_ID \`

  `TF_VAR_openstack_domain_name=$OS_USER_DOMAIN_NAME \`

  `INSTANCE=<CLUSTER_NAME> make apply`

10. Use the kubeconfig downloaded by Terraform in current directory to access the cluster
12. If you want to stop and erase the infrastructure

  `INSTANCE=<CLUSTER_NAME> make destroy`
