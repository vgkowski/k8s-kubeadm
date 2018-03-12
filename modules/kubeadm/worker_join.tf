resource "null_resource" "kubeadm_worker_join" {

  count = "${var.worker_count}"

  connection {
    host        = "${element(var.worker_ip,count.index)}"

    type        = "ssh"
    user        = "core"
    private_key = "${var.private_key}"

    bastion_host        = "${var.bastion_ip}"
    bastion_port        = "22"
    bastion_user        = "core"
    bastion_private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${join(",",var.worker_dependencies)}",
      "sudo mkdir -p /opt/cni/bin",
      "CNI_VERSION=\"${var.cni_version}\"",
      "sudo curl -L \"https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-amd64-$${CNI_VERSION}.tgz\" | sudo tar -C /opt/cni/bin -xz",
      "sudo mkdir -p /opt/bin",
      "RELEASE=\"${var.kube_version}\"",
      "cd /opt/bin",
      "sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/$${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}",
      "sudo chmod +x {kubeadm,kubelet,kubectl}",

      "sudo sh -c \"curl -sSL \\\"https://raw.githubusercontent.com/kubernetes/kubernetes/$${RELEASE}/build/debs/kubelet.service\\\" | sed \\\"s:/usr/bin:/opt/bin:g\\\" > /etc/systemd/system/kubelet.service\"",
      "sudo mkdir -p /etc/systemd/system/kubelet.service.d",
      "sudo sh -c \"curl -sSL \\\"https://raw.githubusercontent.com/kubernetes/kubernetes/$${RELEASE}/build/debs/10-kubeadm.conf\\\" | sed \\\"s:/usr/bin:/opt/bin:g\\\" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf\"",
      "sudo systemctl enable kubelet && sudo systemctl start kubelet",

      "sudo kubeadm join --discovery-token-unsafe-skip-ca-verification --ignore-preflight-errors=all --token=${var.token} ${var.apiserver_internal_dns}:${var.apiserver_port}"
    ]
  }

  depends_on = ["null_resource.kubeadm_init"]
}