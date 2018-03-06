variable "cluster_name" {
  type = "string"
}

variable "hostname_infix" {
  type = "string"
}

variable "public_key" {
  type = "list"
}

variable "resolvconf_content" {
  type = "string"
}

variable "instance_count" {
  type = "string"
}

variable "upstream_proxy_ip" {
  type = "string"
}

variable "upstream_proxy_port" {
  type = "string"
}

variable "internal_proxy_ip" {
  type = "string"
}

variable "internal_proxy_port" {
  type = "string"
}