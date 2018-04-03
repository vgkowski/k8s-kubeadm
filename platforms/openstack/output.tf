output "bastion-ip" {
  value = "${openstack_networking_floatingip_v2.bastion.*.address}"
}

output "masters-ip" {
  value = "${openstack_networking_port_v2.master.*.all_fixed_ips}"
}

output "workers-ip" {
  value = "${openstack_networking_port_v2.worker.*.all_fixed_ips}"
}

output "cloud-init" {
  value = "${module.master_cloudconfig.cloud_config}"
}
