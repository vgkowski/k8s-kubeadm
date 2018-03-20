INSTANCE ?= 
OPENSTACK_TF_FILES ?= platforms/openstack

init:
	terraform init platforms/openstack

apply: init
	terraform apply -auto-approve -var-file=env/$(INSTANCE)/terraform.tfvars -state=env/$(INSTANCE)/terraform.tfstate $(OPENSTACK_TF_FILES)

destroy:
	terraform destroy -force -var-file=env/$(INSTANCE)/terraform.tfvars -state=env/$(INSTANCE)/terraform.tfstate $(OPENSTACK_TF_FILES)

## ssh into bastion host
ssh-bastion:
	ssh -A -i env/$(INSTANCE)/id_rsa_core -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no core@$(shell terraform output -state=env/$(INSTANCE)/terraform.tfstate bastion-ip)

k8s-cleanup:
	kubectl get deployment --no-headers=true --all-namespaces |sed -r 's/(\S+)\s+(\S+).*/kubectl --namespace \1 delete deployment \2/e'
	kubectl get service --no-headers=true --all-namespaces |sed -r 's/(\S+)\s+(\S+).*/kubectl --namespace \1 delete service \2/e'

