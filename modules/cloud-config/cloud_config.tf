data "template_file" "cloudconf" {
  template = "${file("${path.module}/resources/cloud_config.yaml")}"

  vars {
    user        = "${var.cloud_username}"
    password    = "${var.cloud_password}"
    auth_url    = "${var.cloud_auth_url}"
    tenant_id   = "${var.cloud_tenant_id}"
    domain_name = "${var.cloud_domain_name}"
    subnet_id   = "${var.cloud_subnet_id}"
    floating_id = "${var.cloud_floating_id}"
  }
}

data "template_file" "cloud_config" {
  count    = "${var.instance_count}"
  template = "${file("${path.module}/resources/cloud_config_core.yaml")}"

  vars {
    public_key         = "${join(",",var.public_key)}"
    resolvconf_content = "${var.resolvconf_content}"
    cluster_name       = "${var.cluster_name}"
    hostname_infix     = "${var.hostname_infix}"
    index              = "${count.index+1}"
    kernel             = "${var.hostname_infix == "worker" ? file("${path.module}/resources/cloud_config_kernel.yaml") : ""}"
    vm-max             = "${var.hostname_infix == "worker" ? file("${path.module}/resources/cloud_config_vm_max.yaml") : ""}"
    cloud-config       = "${var.hostname_infix != "bastion" ? data.template_file.cloudconf.rendered : "" }"
  }
}
