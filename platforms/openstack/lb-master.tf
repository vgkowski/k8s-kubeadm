resource "openstack_lb_loadbalancer_v2" "master_lb" {
  vip_subnet_id         = "${openstack_networking_subnet_v2.subnet.id}"
  name                  = "${var.cluster_name}_master"
  loadbalancer_provider = "${var.openstack_lb_provider}"
  security_group_ids    = ["${openstack_networking_secgroup_v2.lbaas.id}"]
}

resource "openstack_lb_pool_v2" "master_lb_pool" {
  lb_method       = "ROUND_ROBIN"
  protocol        = "TCP"
  name            = "https"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.master_lb.id}"
}

resource "openstack_lb_listener_v2" "master_lb_listener" {
  default_pool_id = "${openstack_lb_pool_v2.master_lb_pool.id}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.master_lb.id}"
  protocol        = "TCP"
  protocol_port   = "${var.apiserver_port}"
  name            = "https"
}

resource "openstack_lb_monitor_v2" "master_lb_monitor" {
  delay       = 30
  max_retries = 3
  pool_id     = "${openstack_lb_pool_v2.master_lb_pool.id}"
  timeout     = 5
  type        = "TCP"
  name        = "https"
}

resource "openstack_lb_member_v2" "master_lb_members" {
  count         = "${var.master_count}"
  address       = "${element(openstack_networking_port_v2.master.*.all_fixed_ips[count.index], 0)}"
  pool_id       = "${openstack_lb_pool_v2.master_lb_pool.id}"
  protocol_port = 6443
  subnet_id     = "${openstack_networking_subnet_v2.subnet.id}"
  weight        = 1
}

resource "openstack_networking_floatingip_v2" "loadbalancer" {
  pool    = "${var.openstack_floatingip_pool}"
  port_id = "${openstack_lb_loadbalancer_v2.master_lb.vip_port_id}"
}