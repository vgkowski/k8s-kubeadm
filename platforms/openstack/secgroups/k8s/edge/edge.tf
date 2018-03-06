resource "openstack_networking_secgroup_rule_v2" "node_ports_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 30000
  port_range_max    = 32767
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "node_port_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 30000
  port_range_max    = 32767
  protocol          = "udp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "squid" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8080
  port_range_max    = 8080
  protocol          = "tcp"
  remote_group_id   = "${var.proxy_secgroups}"
  security_group_id = "${var.secgroup_id}"
}