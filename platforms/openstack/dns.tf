data "openstack_dns_zone_v2" "cluster" {
  name = "${var.openstack_dns_zone}."
}

resource "openstack_dns_recordset_v2" "apiserver_external" {
  count   = "1"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s.%s.", var.cluster_name, var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_networking_floatingip_v2.loadbalancer.address}"]
}

resource "openstack_dns_recordset_v2" "apiserver_internal" {
  count   = "1"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s-internal.%s.", var.cluster_name, var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${openstack_lb_loadbalancer_v2.master_lb.vip_address}"]
}

resource "openstack_dns_recordset_v2" "etcd" {
  count   = "${var.master_count}"
  zone_id = "${data.openstack_dns_zone_v2.cluster.id}"
  name    = "${format("%s-etcd%d.%s.", var.cluster_name, count.index, var.openstack_dns_zone)}"
  type    = "A"
  ttl     = "60"
  records = ["${list(element(openstack_networking_port_v2.master.*.all_fixed_ips[0], count.index))}"]
}