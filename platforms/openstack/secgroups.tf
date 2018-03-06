resource "openstack_networking_secgroup_v2" "bastion" {
  name        = "${var.cluster_name}_bastion"
  description = "bastion rules"
}

module "bastion" {
  source      = "secgroups/bastion"
  secgroup_id = "${openstack_networking_secgroup_v2.bastion.id}"
}



resource "openstack_networking_secgroup_v2" "k8s" {
  name        = "${var.cluster_name}_k8s"
  description = "kubernetes rules"
}

module "k8s" {
  source      = "secgroups/k8s"
  secgroup_id = "${openstack_networking_secgroup_v2.k8s.id}"
  ssh_secgroup_id = "${openstack_networking_secgroup_v2.bastion.id}"
}



resource "openstack_networking_secgroup_v2" "master" {
  name                 = "${var.cluster_name}_k8s_master"
  description          = "Ports needed by Kubernetes masters"
  delete_default_rules = true
}

module "master" {
  source                = "./secgroups/k8s/master"
  secgroup_id           = "${openstack_networking_secgroup_v2.master.id}"
  etcd_secgroup_id      = "${openstack_networking_secgroup_v2.k8s.id}"
  apiserver_secgroup_id = "${openstack_networking_secgroup_v2.k8s.id}"
}

resource "openstack_networking_secgroup_v2" "worker" {
  name                 = "${var.cluster_name}_k8s_worker"
  description          = "Ports needed by Kubernetes workers"
  delete_default_rules = true
}

module "worker" {
  source             = "./secgroups/k8s/worker"
  secgroup_id        = "${openstack_networking_secgroup_v2.worker.id}"
}