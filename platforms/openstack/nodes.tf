# bastion
resource "openstack_compute_instance_v2" "bastion_node" {
  count = "1"
  availability_zone = "${var.openstack_availabilityzone}"
  name  = "${var.cluster_name}-bastion-${count.index+1}"

  image_name = "${var.openstack_image_name}"
  image_id   = "${var.openstack_image_id}"

  flavor_name = "${var.openstack_bastion_flavor_name}"
  flavor_id   = "${var.openstack_bastion_flavor_id}"

  metadata {
    role = "bastion"
  }

  network {
    port = "${openstack_networking_port_v2.bastion.*.id[count.index]}"
  }

  user_data    = "${module.bastion_cloudconfig.cloud_config[count.index]}"
  config_drive = false
}

resource "openstack_compute_floatingip_associate_v2" "bastion" {
  count = "1"

  floating_ip = "${openstack_networking_floatingip_v2.bastion.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.bastion_node.*.id[count.index]}"
}

# masters
resource "openstack_compute_servergroup_v2" "master_group" {
  name     = "${var.cluster_name}-master-group"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "master_node" {
  count = "${var.master_count}"
  availability_zone = "${var.openstack_availabilityzone}"
  name  = "${var.cluster_name}-master-${count.index+1}"

  image_name = "${var.openstack_image_name}"
  image_id   = "${var.openstack_image_id}"

  flavor_name = "${var.openstack_master_flavor_name}"
  flavor_id   = "${var.openstack_master_flavor_id}"

  metadata {
    role = "master"
  }

  network {
    port = "${openstack_networking_port_v2.master.*.id[count.index]}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.master_group.id}"
  }

  user_data    = "${module.master_cloudconfig.cloud_config[count.index]}"
  config_drive = false
}

# workers
resource "openstack_compute_servergroup_v2" "worker_group" {
  name     = "${var.cluster_name}-worker-group"
  policies = ["anti-affinity"]
}

data "openstack_images_image_v2" "worker_image" {
  name = "${var.openstack_image_name}"
  most_recent = true
}

resource "openstack_compute_instance_v2" "worker_node" {
  count = "${var.worker_count}"
  availability_zone = "${var.openstack_availabilityzone}"
  name  = "${var.cluster_name}-worker-${count.index+1}"

  image_name = "${var.openstack_image_name}"
  image_id   = "${var.openstack_image_id}"

  flavor_name = "${var.openstack_worker_flavor_name}"
  flavor_id   = "${var.openstack_worker_flavor_id}"

  metadata {
    role = "worker"
  }

  network {
    port = "${openstack_networking_port_v2.worker.*.id[count.index]}"
  }

  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.worker_group.id}"
  }

  user_data    = "${module.worker_cloudconfig.cloud_config[count.index]}"
  config_drive = false
}

output "bastion floating IP" {
  value = "${openstack_networking_floatingip_v2.bastion.*.address}"
}

output "masters IP" {
  value = "${openstack_networking_port_v2.master.*.all_fixed_ips}"
}

output "workers IP" {
  value = "${openstack_networking_port_v2.worker.*.all_fixed_ips}"
}