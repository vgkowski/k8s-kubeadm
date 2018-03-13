# bastion
resource "openstack_compute_instance_v2" "bastion" {
  count = "1"
  availability_zone = "${var.openstack_availability_zone}"
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

# FIP
resource "openstack_compute_floatingip_associate_v2" "bastion" {
  count = "1"

  floating_ip = "${openstack_networking_floatingip_v2.bastion.*.address[count.index]}"
  instance_id = "${openstack_compute_instance_v2.bastion.*.id[count.index]}"
}

# DNS
resource "openstack_dns_recordset_v2" "bastion" {
  count   = "1"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.",openstack_compute_instance_v2.bastion.name,var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.bastion.*.access_ip_v4}"]
}