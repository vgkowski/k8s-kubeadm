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

variable "cloud_username" {
  type    = "string"
}

variable "cloud_password" {
  type    = "string"
}

variable "cloud_auth_url" {
  type    = "string"
}

variable "cloud_tenant_id" {
  type    = "string"
}

variable "cloud_domain_name" {
  type    = "string"
}

variable "cloud_subnet_id" {
  type    = "string"
}

variable "cloud_floating_id" {
  type    = "string"
}