variable "location" {}
variable "resource_group_name" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "network_security_group_id" {}
variable "ssh_public_key" {}
variable "admin_username" {}

resource "azurerm_public_ip" "public_vm_ip" {
  name                = "public-vm-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "public_nic" {
  name                = "public-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.public_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_vm_ip.id
  }
}

resource "azurerm_network_interface" "private_nic" {
  name                = "private-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.private_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "public_vm" {
  name                = "public-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.public_nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #cloud-config
              package_update: true
              packages:
                - nginx
              runcmd:
                - systemctl enable nginx
                - systemctl start nginx
EOF
  )
}

resource "azurerm_linux_virtual_machine" "private_vm" {
  name                = "private-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  network_interface_ids = [azurerm_network_interface.private_nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
              #cloud-config
              package_update: true
              packages:
                - nginx
              runcmd:
                - systemctl enable nginx
                - systemctl start nginx
EOF
  )
}

# Associate public NSG to public NIC's subnet via subnet association already defined in networking module
# Optionally associate NSG directly to NIC (not necessary here). If you need to attach NSG to NIC:
resource "azurerm_network_interface_security_group_association" "public_nic_nsg_assoc" {
  network_interface_id         = azurerm_network_interface.public_nic.id
  network_security_group_id    = var.network_security_group_id
}

output "public_vm_fqdn_or_ip" {
  value = azurerm_public_ip.public_vm_ip.ip_address
}

output "private_vm_ip" {
  value = azurerm_network_interface.private_nic.private_ip_address
}
