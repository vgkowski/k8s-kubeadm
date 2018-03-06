variable "hostnames" {
  type    = "list"
}

variable "nodes_ip" {
  type = "list"
}

variable "connect_ip" {
  type = "list"
}

variable "connect_count" {
  type    = "string"
}

variable "instance_count" {
  type    = "string"
}

variable "private_key" {
  type    = "string"
}

variable "bastion_host" {
  type    = "string"
}