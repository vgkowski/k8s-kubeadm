output "public_key" {
  value = "${chomp(tls_private_key.core.public_key_openssh)}"
}

output "private_key" {
  value = "${tls_private_key.core.private_key_pem}"
}