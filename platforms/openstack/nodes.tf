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

# edges
resource "openstack_compute_servergroup_v2" "edge_group" {
  name     = "${var.cluster_name}-edge-group"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "edge_node" {
  count = "${var.edge_count}"
  availability_zone = "${var.openstack_availabilityzone}"
  name  = "${var.cluster_name}-edge-${count.index+1}"

  image_name = "${var.openstack_image_name}"
  image_id   = "${var.openstack_image_id}"

  flavor_name = "${var.openstack_edge_flavor_name}"
  flavor_id   = "${var.openstack_edge_flavor_id}"

  metadata {
    role = "edge"
  }

  network {
    port = "${openstack_networking_port_v2.edge.*.id[count.index]}"
  }

  user_data    = "${module.edge_cloudconfig.cloud_config[count.index]}"
  config_drive = false
}

resource "openstack_compute_floatingip_associate_v2" "edge" {
  count = "${var.edge_count}"

  floating_ip = "${openstack_networking_floatingip_v2.edge.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.edge_node.*.id[count.index]}"
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

# Volumes
resource "openstack_blockstorage_volume_v2" "hdd1_volume" {
  count = "${var.worker_count}"
  name        = "${var.cluster_name}-hdd1-${count.index+1}"
  description = "hdd1"
  size        = "${var.lowperf_disk_size}"
}

resource "openstack_blockstorage_volume_v2" "hdd2_volume" {
  count = "${var.worker_count}"
  name        = "${var.cluster_name}-hdd2-${count.index+1}"
  description = "hdd2"
  size        = "${var.lowperf_disk_size}"
}


resource "openstack_compute_instance_v2" "worker_node" {
  depends_on = ["openstack_blockstorage_volume_v2.hdd1_volume",
                "openstack_blockstorage_volume_v2.hdd2_volume"]

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

  block_device {
    boot_index = 0
    delete_on_termination = true
    destination_type = "local"
    source_type = "image"
    uuid = "${data.openstack_images_image_v2.worker_image.id}"
  }
  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = "${var.highperf_disk_size}"
  }

  block_device {
    boot_index            = -1
    delete_on_termination = true
    destination_type      = "local"
    source_type           = "blank"
    volume_size           = "${var.highperf_disk_size}"
  }

  user_data    = "${module.worker_cloudconfig.cloud_config[count.index]}"
  config_drive = false
}

resource "openstack_compute_volume_attach_v2" "worker-hd1" {
  count     = "${var.worker_count}"
  volume_id = "${element(openstack_blockstorage_volume_v2.hdd1_volume.*.id,count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.worker_node.*.id,count.index)}"
}

resource "openstack_compute_volume_attach_v2" "worker-hd2" {
  count     = "${var.worker_count}"
  volume_id = "${element(openstack_blockstorage_volume_v2.hdd2_volume.*.id,count.index)}"
  instance_id = "${element(openstack_compute_instance_v2.worker_node.*.id,count.index)}"
}

output "bastion floating IP" {
  value = "${openstack_networking_floatingip_v2.bastion.*.address}"
}

output "edge floating IP" {
  value = "${openstack_networking_floatingip_v2.edge.*.address}"
}

output "masters IP" {
  value = "${openstack_networking_port_v2.master.*.all_fixed_ips.0}"
}

output "workers IP" {
  value = "${openstack_networking_port_v2.worker.*.all_fixed_ips.0}"
}

output "edges IP" {
  value = "${openstack_networking_port_v2.edge.*.all_fixed_ips.0}"
}