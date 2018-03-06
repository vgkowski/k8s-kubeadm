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
  upstream_proxy_ip   = "${var.upstream_proxy_ip}"
  upstream_proxy_port = "${var.upstream_proxy_port}"
  internal_proxy_ip   = "${openstack_compute_instance_v2.edge_node.0.access_ip_v4}"
  internal_proxy_port = "8080"
}

module "master_cloudconfig" {
  source = "../../modules/cloud-config"

  cluster_name       = "${var.cluster_name}"
  public_key         = ["${module.secrets.public_key}"]
  resolvconf_content = ""
  hostname_infix     = "master"
  instance_count     = "${var.master_count}"
  upstream_proxy_ip   = "${var.upstream_proxy_ip}"
  upstream_proxy_port = "${var.upstream_proxy_port}"
  internal_proxy_ip   = "${openstack_compute_instance_v2.edge_node.0.access_ip_v4}"
  internal_proxy_port = "8080"
}


module "worker_cloudconfig" {
  source  = "../../modules/cloud-config"

  cluster_name       = "${var.cluster_name}"
  public_key         = ["${module.secrets.public_key}"]
  resolvconf_content = ""
  hostname_infix     = "worker"
  instance_count     = "${var.worker_count}"
  upstream_proxy_ip   = "${var.upstream_proxy_ip}"
  upstream_proxy_port = "${var.upstream_proxy_port}"
  internal_proxy_ip   = "${openstack_compute_instance_v2.edge_node.0.access_ip_v4}"
  internal_proxy_port = "8080"
}

module "edge_cloudconfig" {
  source  = "../../modules/cloud-config"

  cluster_name       = "${var.cluster_name}"
  public_key         = ["${module.secrets.public_key}"]
  resolvconf_content = ""
  hostname_infix     = "edge"
  instance_count     = "${var.edge_count}"
  upstream_proxy_ip   = "${var.upstream_proxy_ip}"
  upstream_proxy_port = "${var.upstream_proxy_port}"
  internal_proxy_ip   = ""
  internal_proxy_port = ""
}


module "bastion_hostfile" {
  source = "../../modules/hostfile"

  instance_count = "${1 + var.master_count + var.worker_count + var.edge_count}"
  nodes_ip           = "${concat(openstack_compute_instance_v2.bastion_node.*.access_ip_v4,
                             openstack_compute_instance_v2.master_node.*.access_ip_v4,
                             openstack_compute_instance_v2.worker_node.*.access_ip_v4,
                             openstack_compute_instance_v2.edge_node.*.access_ip_v4)}"

  hostnames      = "${concat(openstack_compute_instance_v2.bastion_node.*.name,
                             openstack_compute_instance_v2.master_node.*.name,
                             openstack_compute_instance_v2.worker_node.*.name,
                             openstack_compute_instance_v2.edge_node.*.name)}"
  private_key    = "${module.secrets.private_key}"
  bastion_host   = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"

  connect_ip     = "${openstack_compute_instance_v2.bastion_node.*.access_ip_v4}"
  connect_count  = "1"
}

module "master_hostfile" {
  source = "../../modules/hostfile"

  instance_count = "${1 + var.master_count + var.worker_count + var.edge_count}"
  nodes_ip           = "${concat(openstack_compute_instance_v2.bastion_node.*.access_ip_v4,
                             openstack_compute_instance_v2.master_node.*.access_ip_v4,
                             openstack_compute_instance_v2.worker_node.*.access_ip_v4,
                             openstack_compute_instance_v2.edge_node.*.access_ip_v4)}"

  hostnames      = "${concat(openstack_compute_instance_v2.bastion_node.*.name,
                             openstack_compute_instance_v2.master_node.*.name,
                             openstack_compute_instance_v2.worker_node.*.name,
                             openstack_compute_instance_v2.edge_node.*.name)}"
  private_key    = "${module.secrets.private_key}"
  bastion_host   = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"

  connect_ip     = "${openstack_compute_instance_v2.master_node.*.access_ip_v4}"
  connect_count  = "${var.master_count}"
}

module "edge_hostfile" {
  source = "../../modules/hostfile"

  instance_count = "${1 + var.master_count + var.worker_count + var.edge_count}"
  nodes_ip           = "${concat(openstack_compute_instance_v2.bastion_node.*.access_ip_v4,
                             openstack_compute_instance_v2.master_node.*.access_ip_v4,
                             openstack_compute_instance_v2.worker_node.*.access_ip_v4,
                             openstack_compute_instance_v2.edge_node.*.access_ip_v4)}"

  hostnames      = "${concat(openstack_compute_instance_v2.bastion_node.*.name,
                             openstack_compute_instance_v2.master_node.*.name,
                             openstack_compute_instance_v2.worker_node.*.name,
                             openstack_compute_instance_v2.edge_node.*.name)}"
  private_key    = "${module.secrets.private_key}"
  bastion_host   = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"

  connect_ip     = "${openstack_compute_instance_v2.edge_node.*.access_ip_v4}"
  connect_count  = "${var.edge_count}"
}

module "worker_hostfile" {
  source = "../../modules/hostfile"

  instance_count = "${1 + var.master_count + var.worker_count + var.edge_count}"
  nodes_ip           = "${concat(openstack_compute_instance_v2.bastion_node.*.access_ip_v4,
                             openstack_compute_instance_v2.master_node.*.access_ip_v4,
                             openstack_compute_instance_v2.worker_node.*.access_ip_v4,
                             openstack_compute_instance_v2.edge_node.*.access_ip_v4)}"

  hostnames      = "${concat(openstack_compute_instance_v2.bastion_node.*.name,
                             openstack_compute_instance_v2.master_node.*.name,
                             openstack_compute_instance_v2.worker_node.*.name,
                             openstack_compute_instance_v2.edge_node.*.name)}"
  private_key    = "${module.secrets.private_key}"
  bastion_host   = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"

  connect_ip     = "${openstack_compute_instance_v2.worker_node.*.access_ip_v4}"
  connect_count  = "${var.worker_count}"
}

module "kubeadm" {
  source = "../../modules/kubeadm"

  master_dependencies = "${concat(
    openstack_compute_instance_v2.master_node.*.id,
    openstack_compute_instance_v2.bastion_node.*.id,
    openstack_compute_instance_v2.edge_node.*.id,
    openstack_networking_floatingip_v2.bastion.*.id,
    openstack_networking_floatingip_v2.edge.*.id
    )}"

  worker_dependencies = "${concat(
    openstack_compute_instance_v2.master_node.*.id,
    openstack_compute_instance_v2.bastion_node.*.id,
    openstack_compute_instance_v2.edge_node.*.id,
    openstack_networking_floatingip_v2.bastion.*.id,
    openstack_networking_floatingip_v2.edge.*.id
    )}"

  master_nodes       = "${openstack_compute_instance_v2.master_node.*.access_ip_v4}"
  master_count       = "${var.master_count}"
  worker_nodes       = "${openstack_compute_instance_v2.worker_node.*.access_ip_v4}"
  worker_count       = "${var.worker_count}"
  edge_nodes         = "${openstack_compute_instance_v2.edge_node.*.access_ip_v4}"
  edge_count         = "${var.edge_count}"
  private_key        = "${module.secrets.private_key}"
  bastion_host       = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"

  kube_version        = "${var.kube_version}"
  cluster_domain      = "${var.cluster_domain}"
  pod_cidr            = "${var.pod_cidr}"
  cluster_public_dns  = "${var.cluster_public_dns}"
  service_cidr        = "${var.service_cidr}"
  apiserver_port      = "${var.apiserver_port}"
  token               = "${var.kube_token}"
  token_ttl           = "${var.kube_token_ttl}"
  calico_version      = "${var.calico_version}"
  calico_cni_version  = "${var.calico_cni_version}"
  flannel_version     = "${var.flannel_version}"
  flannel_mode        = "${var.flannel_mode}"
  proxy_ip            = "${openstack_compute_instance_v2.edge_node.0.access_ip_v4}"
  proxy_port          = "8080"
  kubeadm_installer_version   = "${var.kubeadm_installer_version}"
}

module "kubeapps" {
  source = "../../modules/kubeapps"

  kubeapps_dependencies = "${concat(
    openstack_compute_instance_v2.master_node.*.id,
    openstack_compute_instance_v2.worker_node.*.id,
    openstack_compute_instance_v2.bastion_node.*.id,
    openstack_networking_floatingip_v2.bastion.*.id
    )}"

  master_node       = "${openstack_compute_instance_v2.master_node.0.access_ip_v4}"
  edge_nodes         = "${openstack_compute_instance_v2.edge_node.*.name}"
  bastion_host       = "${element(openstack_networking_floatingip_v2.bastion.*.address,0)}"
  private_key        = "${module.secrets.private_key}"
  apiserver_port     = "${var.apiserver_port}"
  apiserver_nodeport = "${var.apiserver_nodeport}"
  helm_version       = "${var.helm_version}"

}