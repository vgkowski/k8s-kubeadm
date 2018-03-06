resource "template_dir" "kube_apps" {
  source_dir      = "${path.module}/resources"
  destination_dir = "./generated/kubeapps"
}


resource "null_resource" "kube_apps" {

  connection {
    host        = "${var.master_ip}"
    type        = "ssh"
    user        = "core"
    private_key = "${var.private_key}"

    bastion_host        = "${var.bastion_ip}"
    bastion_port        = "22"
    bastion_user        = "core"
    bastion_private_key = "${var.private_key}"
  }

  provisioner "file" {
    source      = "${template_dir.kube_apps.destination_dir}"
    destination = "/home/core"
  }

  provisioner "remote-exec" {
    inline = [
      // workaround to introduce a depency on required modules
      "echo ${join(",",var.kubeapps_dependencies)}",
      "chmod u+x /home/core/kubeapps/kube-apps.sh",
      "/home/core/kubeapps/kube-apps.sh /home/core/.kube/config /home/core/kubeapps"
    ]
  }
}