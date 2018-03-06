variable "master_node" {
  type = "string"
}

variable "edge_nodes" {
  type = "list"
}

variable "private_key" {
  type = "string"
}

variable "bastion_host" {
  type = "string"
}

variable "kubeapps_dependencies" {
  type = "list"
}

variable "apiserver_port" {
  type    = "string"
}

variable "apiserver_nodeport" {
  type    = "string"
}

variable "helm_version" {
  type    = "string"
}