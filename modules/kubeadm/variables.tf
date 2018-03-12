variable "master_ip" {
  type = "list"
}

variable "worker_ip" {
  type = "list"
}

variable "worker_count" {
  type = "string"
}

variable "bastion_ip" {
  type    = "string"
}

variable "private_key" {
  type    = "string"
}

variable "apiserver_port" {
  type    = "string"
}

variable "apiserver_internal_dns" {
  type    = "string"
}

variable "apiserver_external_dns" {
  type    = "string"
}

variable "kube_version" {
  type    = "string"
}

variable "pod_cidr" {
  type    = "string"
}

variable "service_cidr" {
  type    = "string"
}

variable "cluster_domain" {
  type    = "string"
}

variable "token" {
  type = "string"
}

variable "token_ttl" {
  type    = "string"
}

variable "master_dependencies" {
  type    = "list"
}

variable "worker_dependencies" {
  type    = "list"
}

variable "flannel_version" {
  type    = "string"
}

variable "flannel_mode" {
  type    = "string"
}

variable "calico_version" {
  type    = "string"
}

variable "calico_cni_version" {
  type    = "string"
}

variable "cloud_provider" {
  type    = "string"
}

variable "cni_version" {
  type    = "string"
}