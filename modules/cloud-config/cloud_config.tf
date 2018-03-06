data "template_file" "cloud_config" {
  count    = "${var.instance_count}"
  template = "${file("${path.module}/resources/cloud_config_core.yaml")}"
  vars {
    public_key         = "${join(",",var.public_key)}"
    resolvconf_content = "${var.resolvconf_content}"
    cluster_name       = "${var.cluster_name}"
    hostname_infix     = "${var.hostname_infix}"
    index              = "${count.index+1}"
    kernel            = "${var.hostname_infix == "worker" ? file("${path.module}/resources/cloud_config_kernel.yaml") : ""}"
  }
}