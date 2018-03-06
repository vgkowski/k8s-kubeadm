resource "openstack_networking_secgroup_rule_v2" "node_ports" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 30000
  port_range_max    = 32767
  protocol          = "tcp"
  remote_group_id   = "${var.secgroup_id}"
  security_group_id = "${var.secgroup_id}"
}