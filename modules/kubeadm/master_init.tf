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
    dns_domain         = "${var.cluster_domain}"
    service_cidr       = "${var.service_cidr}"
    pod_cidr           = "${var.pod_cidr}"
    kube_version       = "${var.kube_version}"
    token              = "${var.token}"
    token_ttl          = "${var.token_ttl}"
    apiserver_dns      = "- ${var.apiserver_external_dns}\n- ${var.apiserver_internal_dns}\n"
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
      "sudo mkdir -p /opt/cni/bin",
      "CNI_VERSION=\"v0.6.0\"",
      "sudo curl -L \"https://github.com/containernetworking/plugins/releases/download/$${CNI_VERSION}/cni-plugins-amd64-$${CNI_VERSION}.tgz\" | sudo tar -C /opt/cni/bin -xz",
      "sudo mkdir -p /opt/bin",
      "RELEASE=\"$(curl -sSL https://dl.k8s.io/release/stable.txt)\"",
      "cd /opt/bin",
      "sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/$${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}",
      "sudo chmod +x {kubeadm,kubelet,kubectl}",

      "sudo sh -c \"curl -sSL \\\"https://raw.githubusercontent.com/kubernetes/kubernetes/$${RELEASE}/build/debs/kubelet.service\\\" | sed \\\"s:/usr/bin:/opt/bin:g\\\" > /etc/systemd/system/kubelet.service\"",
      "sudo mkdir -p /etc/systemd/system/kubelet.service.d",
      "sudo sh -c \"curl -sSL \\\"https://raw.githubusercontent.com/kubernetes/kubernetes/$${RELEASE}/build/debs/10-kubeadm.conf\\\" | sed \\\"s:/usr/bin:/opt/bin:g\\\" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf\"",
      "sudo systemctl enable kubelet && sudo systemctl start kubelet",

      "sudo kubeadm init --ignore-preflight-errors=all --config=/home/core/kubeadm/kubeadm_master.cfg",
      "mkdir -p /home/core/.kube",
      "sudo cp /etc/kubernetes/admin.conf /home/core/.kube/config",
      "sudo chown $(id -u):$(id -g) /home/core/.kube/config",
      "/opt/bin/kubectl apply -f /home/core/kubeadm/kube-network/rbac.yaml",
      "/opt/bin/kubectl apply -f /home/core/kubeadm/kube-network/canal.yaml"
    ]
  }
}