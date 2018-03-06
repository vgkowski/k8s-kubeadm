variable "secgroup_id" {
  type = "string"
}

variable "etcd_secgroup_id" {
  type        = "string"
  description = <<EOF
The security group ID authorized to access ETCD ports (generally the whole k8s cluster)
EOF
}

variable "apiserver_secgroup_id" {
  type        = "string"
  description = <<EOF
The security group ID authorized to access API server ports (generally the whole k8s cluster)
EOF
}