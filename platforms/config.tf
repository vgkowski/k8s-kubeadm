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
  default = "v1.9.1"

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
  default = "443"

  description = "The secured port to access the API server"
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

variable "helm_version" {
  type    = "string"
  default = "v2.7.2"
  description = "The version of helm used for local storage configuration"
}