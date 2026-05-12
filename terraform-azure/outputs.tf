output "public_vm_ip" {
  value = module.vm.public_vm_fqdn_or_ip
}

output "private_vm_ip" {
  value = module.vm.private_vm_ip
}

output "ssh_public_key" {
  value = module.ssh_key.public_key_openssh
}
