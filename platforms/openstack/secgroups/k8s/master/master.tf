
resource "openstack_networking_secgroup_rule_v2" "etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 2379
  port_range_max    = 2380
  protocol          = "tcp"
  remote_group_id   = "${var.etcd_secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "bootstrap_etcd" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 12379
  port_range_max    = 12380
  protocol          = "tcp"
  remote_group_id   = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "api_server" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 6443
  port_range_max = 6443
  remote_group_id   = "${var.apiserver_secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}


resource "openstack_networking_secgroup_rule_v2" "kube_scheduler" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 10251
  port_range_max = 10251
  remote_group_id  = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "kube_controller_manager" {
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 10252
  port_range_max = 10252
  remote_group_id  = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}