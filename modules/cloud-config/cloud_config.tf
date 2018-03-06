data "template_file" "docker_env" {
  template = "-e UPSTREAM_PROXY=$${server} -e UPSTREAM_PORT=$${port}"
  vars {
    server = "${var.upstream_proxy_ip}"
    port   = "${var.upstream_proxy_port}"
  }
}

data "template_file" "proxy_server" {
  template = "${file("${path.module}/resources/cloud_config_proxy_server.yaml")}"
  vars {
    upstream_proxy = "${var.upstream_proxy_ip == "" ? "" : data.template_file.docker_env.rendered }"
  }
}

data "template_file" "proxy_docker" {
  template = "${file("${path.module}/resources/cloud_config_proxy_docker.yaml")}"
  vars {
    proxy_server       = "${var.hostname_infix == "edge" ? var.upstream_proxy_ip : var.internal_proxy_ip}"
    proxy_port         = "${var.hostname_infix == "edge" ? var.upstream_proxy_port : var.internal_proxy_port}"  }
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

    proxy_docker      = "${var.upstream_proxy_ip == "" && var.hostname_infix == "edge" ? "" : data.template_file.proxy_docker.rendered }"
    disks             = "${var.hostname_infix == "worker" ? file("${path.module}/resources/cloud_config_disks.yaml") : ""}"
    proxy_server      = "${var.hostname_infix == "edge" ? data.template_file.proxy_server.rendered : ""}"
    kernel            = "${var.hostname_infix == "worker" ? file("${path.module}/resources/cloud_config_kernel.yaml") : ""}"
  }
}