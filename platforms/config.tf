variable "cluster_name" {
  type    = "string"
  default = "k8stest"

  description = <<EOF
The name of the cluster.

Note: This field MUST be set manually prior to creating the cluster.
Warning: Special characters in the name like '.' may cause errors on OpenStack platforms due to resource name constraints.
EOF
}

variable "kube_version" {
  type    = "string"
  default = "v1.7.6"

  description = <<EOF
The version of Kubernetes to install
EOF
}


variable "master_count" {
  type    = "string"
  default = "1"

  description = <<EOF
The number of master nodes to be created.
EOF
}

variable "worker_count" {
  type    = "string"
  default = "1"

  description = <<EOF
The number of worker nodes to be created.
EOF
}

variable "edge_count" {
  type    = "string"
  default = "1"

  description = <<EOF
The number of edge nodes to be created.
EOF
}

variable "service_cidr" {
  type    = "string"
  default = "10.96.0.0/12"

  description = <<EOF
This declares the IP range to assign Kubernetes service cluster IPs in CIDR notation.
The maximum size of this IP range is /12
EOF
}

variable "pod_cidr" {
  type    = "string"
  default = "10.244.0.0/16"

  description = "This declares the IP range to assign Kubernetes pod IPs in CIDR notation."
}

variable "cluster_domain" {
  type    = "string"
  default = "cluster.local"

  description = ""
}

variable "cluster_public_dns" {
  type    = "string"
  default = ""

  description = "This declare the public DNS to access the cluster from outside"
}

variable "apiserver_port" {
  type    = "string"
  default = "6443"

  description = "The secured port to access the API server from inside the cluster"
}

variable "apiserver_nodeport" {
  type    = "string"
  default = "31000"

  description = <<EOF
The secured port to access the API server from outside the cluster. Used in a NodePort service on edge nodes.
EOF
}

variable "kube_token" {
  type    = "string"
  default = ""

  description = "The token used to bootstrap the K8S cluster"
}

variable "kube_token_ttl" {
  type    = "string"
  default = "0s"

  description = "The TTL of tokens used within the cluster"
}

variable "calico_version" {
  type    = "string"
  default = "v2.6.2"
  description = "The version of Calico"
}

variable "calico_cni_version" {
  type    = "string"
  default = "v1.11.0"
  description = "The version of Calico CNI"
}

variable "flannel_version" {
  type    = "string"
  default = "v0.9.1"
  description = "The version of Flannel used"
}

variable "flannel_mode" {
  type    = "string"
  default = "vxlan"
  description = "The flannel mode used (vxlan for clouds or hostgw for baremetal)"
}

variable "lowperf_disk_size" {
  type    = "string"
  default = "25"
  description = "The size of disk to provision for low performance. For openstack it's Cinder disk, 2 disks per VM"
}

variable "highperf_disk_size" {
  type    = "string"
  default = "25"
  description = <<EOF
The size of disk to provision for high performance.
For cloudwatt it's ephemeral SSD disks, 2 disks per VM.
For devwatt it's extremIO block storage.
EOF
}

variable "upstream_proxy_ip" {
  type    = "string"
  default = ""
  description = "The IP of the external proxy to access Internet"
}

variable "upstream_proxy_port" {
  type    = "string"
  default = ""
  description = "The port of the external proxy to access Internet"
}

variable "kubeadm_installer_version" {
  type    = "string"
  default = "v1.9"
  description = "The version of kubeadm-installer-coreos used"
}

variable "helm_version" {
  type    = "string"
  default = "v2.7.2"
  description = "The version of helm used for local storage configuration"
}