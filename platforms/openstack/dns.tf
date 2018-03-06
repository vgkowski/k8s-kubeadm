data "openstack_dns_zone_v2" "cluster" {
  name = "${var.openstack_dns_zone}."
}

resource "openstack_dns_recordset_v2" "apiserver" {
  count   = "1"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.", var.cluster_name, var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_networking_floatingip_v2.loadbalancer.address}"]
}

resource "openstack_dns_recordset_v2" "bastion" {
  count   = "1"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.",openstack_compute_instance_v2.bastion_node.name,var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_compute_instance_v2.bastion_node.*.access_ip_v4}"]
}

resource "openstack_dns_recordset_v2" "master" {
  count   = "${var.master_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.",element(openstack_compute_instance_v2.master_node.*.name,count.index),var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${element(openstack_compute_instance_v2.master_node.*.access_ip_v4,count.index)}"]
}

resource "openstack_dns_recordset_v2" "worker" {
  count   = "${var.worker_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.",element(openstack_compute_instance_v2.worker_node.*.name,count.index),var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${element(openstack_compute_instance_v2.worker_node.*.access_ip_v4,count.index)}"]
}

resource "openstack_dns_recordset_v2" "etcd" {
  count   = "${var.master_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s-etcd%d.%s.", var.cluster_name, count.index, var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${list(element(openstack_networking_port_v2.master.*.all_fixed_ips[0], count.index))}"]
}