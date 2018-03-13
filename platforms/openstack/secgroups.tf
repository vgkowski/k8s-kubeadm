# Infrastructure
resource "openstack_networking_secgroup_v2" "bastion" {
  name        = "${var.cluster_name}_secgroup_bastion"
  description = "bastion rules"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.bastion.id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.bastion.id}"
}

# K8S topology
resource "openstack_networking_secgroup_v2" "k8s" {
  name        = "${var.cluster_name}_secgroup_k8s"
  description = "kubernetes rules"
}

module "k8s" {
  source      = "secgroups/k8s"
  secgroup_id = "${openstack_networking_secgroup_v2.k8s.id}"
  ssh_secgroup_id = "${openstack_networking_secgroup_v2.bastion.id}"
}

resource "openstack_networking_secgroup_v2" "master" {
  name                 = "${var.cluster_name}_secgroup_k8s_master"
  description          = "Ports needed by Kubernetes masters"
  delete_default_rules = true
}

module "master" {
  source                 = "./secgroups/k8s/master"
  secgroup_id            = "${openstack_networking_secgroup_v2.master.id}"
  etcd_secgroup_id       = "${openstack_networking_secgroup_v2.k8s.id}"
  apiserver_secgroup_id  = "${openstack_networking_secgroup_v2.k8s.id}"
  apiserver_secgroup_id2 = "${openstack_networking_secgroup_v2.lbaas.id}"
}

resource "openstack_networking_secgroup_v2" "worker" {
  name                 = "${var.cluster_name}_secgroup_k8s_worker"
  description          = "Ports needed by Kubernetes workers"
  delete_default_rules = true
}

module "worker" {
  source             = "./secgroups/k8s/worker"
  secgroup_id        = "${openstack_networking_secgroup_v2.worker.id}"
}

resource "openstack_networking_secgroup_v2" "lbaas" {
  name                 = "${var.cluster_name}_secgroup_lbaas"
  description          = "Ports needed by the LBaaS"
  delete_default_rules = true
}

module "lbaas" {
  source             = "./secgroups/lbaas"
  secgroup_id        = "${openstack_networking_secgroup_v2.lbaas.id}"
}