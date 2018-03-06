resource "openstack_networking_router_v2" "router" {
  name             = "${var.cluster_name}_router"
  admin_state_up   = "true"
  external_gateway = "${var.openstack_external_gateway_id}"
}

resource "openstack_networking_network_v2" "network" {
  name           = "${var.cluster_name}_network"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "${var.cluster_name}_subnet"
  network_id = "${openstack_networking_network_v2.network.id}"
  cidr       = "${var.openstack_subnet_cidr}"
  ip_version = 4

  dns_nameservers = ["${var.openstack_dns_nameservers}"]
}

resource "openstack_networking_router_interface_v2" "interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
}

# master

resource "openstack_networking_port_v2" "master" {
  count              = "${var.master_count}"
  name               = "${var.cluster_name}_port_master_${count.index+1}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${openstack_networking_secgroup_v2.k8s.id}","${openstack_networking_secgroup_v2.master.id}"]
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


# worker

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


resource "openstack_networking_port_v2" "bastion" {
  count              = "1"
  name               = "${var.cluster_name}_port_bastion_${count.index+1}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${openstack_networking_secgroup_v2.bastion.id}"]
  admin_state_up     = "true"

  fixed_ip {
    subnet_id = "${openstack_networking_subnet_v2.subnet.id}"
  }
}

resource "openstack_networking_floatingip_v2" "bastion" {
  count = "1"
  pool  = "${var.openstack_floatingip_pool}"
}

# edge

resource "openstack_networking_port_v2" "edge" {
  count              = "${var.edge_count}"
  name               = "${var.cluster_name}_port_edge_${count.index+1}"
  network_id         = "${openstack_networking_network_v2.network.id}"
  security_group_ids = ["${openstack_networking_secgroup_v2.k8s.id}","${openstack_networking_secgroup_v2.edge.id}"]
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

resource "openstack_networking_floatingip_v2" "edge" {
  count = "${var.edge_count}"
  pool  = "${var.openstack_floatingip_pool}"
}