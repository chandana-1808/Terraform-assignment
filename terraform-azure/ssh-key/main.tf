variable "key_name" {
  default = "tf-az-key"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "private_key_pem" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "public_key_openssh" {
  value = tls_private_key.ssh_key.public_key_openssh
}
