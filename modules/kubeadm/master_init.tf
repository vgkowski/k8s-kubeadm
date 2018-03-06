resource "template_dir" "kubeadm" {
  source_dir      = "${path.module}/resources"
  destination_dir = "./generated/kubeadm"

  vars {
    pod_cidr           = "${var.pod_cidr}"
    flannel_mode       = "${var.flannel_mode}"
    calico_version     = "${var.calico_version}"
    calico_cni_version = "${var.calico_cni_version}"
    flannel_version    = "${var.flannel_version}"

    apiserver_ip       = "0.0.0.0"
    port               = "${var.apiserver_port}"
    dns_domain         = "${var.cluster_domain}"
    service_cidr       = "${var.service_cidr}"
    pod_cidr           = "${var.pod_cidr}"
    kube_version       = "${var.kube_version}"
    token              = "${var.token}"
    token_ttl          = "${var.token_ttl}"
    apiserver_dns      = "${var.apiserver_dns}"
  }
}


resource "null_resource" "kubeadm_init" {

  connection {
    host        = "${element(var.master_ip,0)}"
    type        = "ssh"
    user        = "core"
    private_key = "${var.private_key}"

    bastion_host        = "${var.bastion_ip}"
    bastion_port        = "22"
    bastion_user        = "core"
    bastion_private_key = "${var.private_key}"
  }

  provisioner "file" {
    source      = "${template_dir.kubeadm.destination_dir}"
    destination = "/home/core"
  }


  provisioner "remote-exec" {
    inline = [
      // workaround to introduce a depency on required modules
      "echo ${join(",",var.master_dependencies)}",
      "docker run -it -e K8S_VERSION=${var.kube_version} -v /etc:/rootfs/etc -v /opt:/rootfs/opt -v /usr/bin:/rootfs/usr/bin vgkowski/kubeadm-installer-coreos:${var.kubeadm_installer_version}",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable kubelet",
      "sudo kubeadm reset",
      "sudo systemctl restart kubelet",
      "sudo kubeadm init --ignore-preflight-errors=all --config=/home/core/kubeadm/kubeadm_master.cfg",
      "mkdir -p /home/core/.kube",
      "sudo cp /etc/kubernetes/admin.conf /home/core/.kube/config",
      "sudo chown $(id -u):$(id -g) /home/core/.kube/config",
      "/opt/bin/kubectl apply -f /home/core/kubeadm/kube-network/rbac.yaml",
      "/opt/bin/kubectl apply -f /home/core/kubeadm/kube-network/canal.yaml"
    ]
  }
}