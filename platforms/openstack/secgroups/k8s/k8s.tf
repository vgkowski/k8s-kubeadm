resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_group_id   = "${var.ssh_secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_group_id   = "${var.ssh_secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "cAdvisor" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 4194
  port_range_max    = 4194
  protocol          = "tcp"
  remote_group_id   = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "flannel" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8472
  port_range_max    = 8472
  protocol          = "udp"
  remote_group_id   = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "kubelet" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10250
  port_range_max    = 10250
  protocol          = "tcp"
  remote_group_id   = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

resource "openstack_networking_secgroup_rule_v2" "kubelet_readonly" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 10255
  port_range_max    = 10255
  protocol          = "tcp"
  remote_group_id   = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}

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
