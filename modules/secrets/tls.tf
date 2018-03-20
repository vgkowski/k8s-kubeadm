resource "tls_private_key" "core" {
  algorithm = "RSA"
}

resource "null_resource" "export" {
  provisioner "local-exec" {
    command = "echo '${tls_private_key.core.private_key_pem}' > env/$${INSTANCE}/id_rsa_core && chmod 0600 env/$${INSTANCE}/id_rsa_core"
  }

  provisioner "local-exec" {
    command = "echo '${tls_private_key.core.public_key_openssh}' > env/$${INSTANCE}/id_rsa_core.pub"
  }
}
