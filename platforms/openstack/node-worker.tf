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
  availability_zone = "${var.openstack_availability_zone}"
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

resource "openstack_networking_port_v2" "worker" {
  count              = "${var.worker_count}"
  name               = "${var.cluster_name}_port_worker_${count.index+1}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${openstack_networking_secgroup_v2.k8s.id}","${openstack_networking_secgroup_v2.worker.id}"]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
  }

  allowed_address_pairs {
    ip_address = "${var.service_cidr}"
  }

  allowed_address_pairs {
    ip_address = "${var.pod_cidr}"
  }
}

# DNS
resource "openstack_dns_recordset_v2" "worker" {
  count   = "${var.worker_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.",element(openstack_compute_instance_v2.worker_node.*.name,count.index),var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${element(openstack_compute_instance_v2.worker_node.*.access_ip_v4,count.index)}"]
}
