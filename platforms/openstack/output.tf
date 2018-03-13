output "bastion floating IP" {
  value = "${openstack_networking_floatingip_v2.bastion.*.address}"
}

output "masters IP" {
  value = "${openstack_networking_port_v2.master.*.all_fixed_ips}"
}

output "workers IP" {
  value = "${openstack_networking_port_v2.worker.*.all_fixed_ips}"
}