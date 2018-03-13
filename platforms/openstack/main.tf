provider "openstack" {
  insecure = "${var.openstack_insecure_api}"
}

module "secrets" {
  source = "../../modules/secrets"
}

module "bastion_cloudconfig" {
  source = "../../modules/cloud-config"

  cluster_name        = "${var.cluster_name}"
  public_key          = ["${module.secrets.public_key}"]
  resolvconf_content  = ""
  hostname_infix      = "bastion"
  instance_count      = "1"

  cloud_username      = "${var.openstack_username}"
  cloud_password      = "${var.openstack_password}"
  cloud_auth_url      = "${var.openstack_auth_url}"
  cloud_tenant_id     = "${var.openstack_tenant_id}"
  cloud_domain_name   = "${var.openstack_domain_name}"
  cloud_subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
  cloud_floating_id   = "${var.openstack_floatingip_pool}"
}

module "master_cloudconfig" {
  source = "../../modules/cloud-config"

  cluster_name       = "${var.cluster_name}"
  public_key         = ["${module.secrets.public_key}"]
  resolvconf_content = ""
  hostname_infix     = "master"
  instance_count     = "${var.master_count}"

  cloud_username      = "${var.openstack_username}"
  cloud_password      = "${var.openstack_password}"
  cloud_auth_url      = "${var.openstack_auth_url}"
  cloud_tenant_id     = "${var.openstack_tenant_id}"
  cloud_domain_name   = "${var.openstack_domain_name}"
  cloud_subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
  cloud_floating_id   = "${var.openstack_floating_id}"
}


module "worker_cloudconfig" {
  source  = "../../modules/cloud-config"

  cluster_name       = "${var.cluster_name}"
  public_key         = ["${module.secrets.public_key}"]
  resolvconf_content = ""
  hostname_infix     = "worker"
  instance_count     = "${var.worker_count}"

  cloud_username      = "${var.openstack_username}"
  cloud_password      = "${var.openstack_password}"
  cloud_auth_url      = "${var.openstack_auth_url}"
  cloud_tenant_id     = "${var.openstack_tenant_id}"
  cloud_domain_name   = "${var.openstack_domain_name}"
  cloud_subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
  cloud_floating_id   = "${var.openstack_floatingip_pool}"
}

module "kubeadm" {
  source = "../../modules/kubeadm"

  master_dependencies = "${concat(
    openstack_compute_instance_v2.master_node.*.id,
    openstack_compute_instance_v2.bastion_node.*.id,
    openstack_networking_floatingip_v2.bastion.*.id
    )}"

  worker_dependencies = "${concat(
    openstack_compute_instance_v2.master_node.*.id,
    openstack_compute_instance_v2.bastion_node.*.id,
    openstack_networking_floatingip_v2.bastion.*.id
    )}"

  apiserver_external_dns      = "${format("%s.%s", var.cluster_name, var.openstack_dns_zone)}"
  apiserver_internal_dns      = "${format("%s-internal.%s", var.cluster_name, var.openstack_dns_zone)}"

  master_ip          = "${openstack_compute_instance_v2.master_node.*.access_ip_v4}"
  worker_ip          = "${openstack_compute_instance_v2.worker_node.*.access_ip_v4}"
  worker_count       = "${var.worker_count}"
  private_key        = "${module.secrets.private_key}"
  bastion_ip         = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"

  kube_version        = "${var.kube_version}"
  cluster_domain      = "${var.cluster_domain}"
  pod_cidr            = "${var.pod_cidr}"
  service_cidr        = "${var.service_cidr}"
  apiserver_port      = "${var.apiserver_port}"
  token               = "${var.kube_token}"
  token_ttl           = "${var.kube_token_ttl}"
  calico_version      = "${var.calico_version}"
  calico_cni_version  = "${var.calico_cni_version}"
  cni_version         = "${var.cni_version}"
  flannel_version     = "${var.flannel_version}"
  flannel_mode        = "${var.flannel_mode}"

  cloud_provider      = "openstack"
}

module "kubeapps" {
  source = "../../modules/kubeapps"

  kubeapps_dependencies = "${concat(
    openstack_compute_instance_v2.master_node.*.id,
    openstack_compute_instance_v2.worker_node.*.id,
    openstack_compute_instance_v2.bastion_node.*.id,
    openstack_networking_floatingip_v2.bastion.*.id,
    list(module.kubeadm.kubeconfig)
    )}"

  master_ip       = "${openstack_compute_instance_v2.master_node.0.access_ip_v4}"
  bastion_ip       = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"
  private_key        = "${module.secrets.private_key}"
}
