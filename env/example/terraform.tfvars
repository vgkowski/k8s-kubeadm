
openstack_master_flavor_name  = "n2.cw.standard-4"
openstack_worker_flavor_name  = "i2.cw.largessd-4"
openstack_bastion_flavor_name = "n2.cw.standard-1"
openstack_edge_flavor_name    = "n2.cw.standard-1"
openstack_image_name          = "coreos-latest"
openstack_external_gateway_id = "6ea98324-0f14-49f6-97c0-885d1b8dc517"
openstack_subnet_cidr         = "192.168.206.0/24"

kube_token         = "7fe841.9261ad1b7f292196"
cluster_public_dns = "k8sdev.dynu.net"
cluster_name       = "k8sdev"

worker_count = "2"
edge_count   = "1"
kube_version = "v1.9.1"