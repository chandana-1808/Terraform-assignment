terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "eastus"
}

module "networking" {
  source              = "./networking"
  prefix              = "tf-az"
  location            = var.location
  rg_name             = "terraform-rg"
  vnet_name           = "vnet"
  vnet_address_space  = ["10.0.0.0/16"]
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
}

module "ssh_key" {
  source = "./ssh-key"
  key_name = "tf-az-key"
}

module "vm" {
  source             = "./vm"
  location           = var.location
  resource_group_name = module.networking.rg_name
  public_subnet_id   = module.networking.public_subnet_id
  private_subnet_id  = module.networking.private_subnet_id
  network_security_group_id = module.networking.public_nsg_id
  ssh_public_key     = module.ssh_key.public_key_openssh
  admin_username     = "azureuser"
}
