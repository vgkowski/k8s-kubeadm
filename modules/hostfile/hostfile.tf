data "template_file" "hosts" {
  count = "${var.instance_count}"
  template = "$${ip} $${name}"
  vars {
    ip    = "${element(var.nodes_ip,count.index)}"
    name  = "${element(var.hostnames,count.index)}"
  }
}

resource "null_resource" "hostfile" {
  count = "${var.connect_count}"

  connection {
    host        = "${element(var.connect_ip,count.index)}"
    type        = "ssh"
    user        = "core"
    private_key = "${var.private_key}"

    bastion_host        = "${var.bastion_host}"
    bastion_port        = "22"
    bastion_user        = "core"
    bastion_private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      " echo \"\n${join("\n",data.template_file.hosts.*.rendered)}\" | sudo tee -a /etc/hosts"
    ]
  }
}