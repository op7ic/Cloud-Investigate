###############################################################
# Author      : Jerzy 'Yuri' Kramarz (op7ic)                  #
# Version     : 1.0                                           #
# Type        : Terraform/Ansible                             #
# Description : Cloud-Investigate. See README.md for details  # 
# License     : See LICENSE for details                       #   
###############################################################



############################################################
# Provider And Resource Group Definition
############################################################

# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create resource group
# Note that all deployment relies on this resource group so we set manual "depends_on" everywhere
resource "azurerm_resource_group" "resourcegroup" {
  location            = var.region
  name                = var.resource_group
}

############################################################
# Public IP (we use this to configure firewall)
############################################################

# Get Public IP of my current system
data "http" "public_IP" {
  url = "https://ipinfo.io/json"
  request_headers = {
    Accept = "application/json"
  }
}

############################################################
# Local variables used in this template
############################################################
# Define local variables which we will use across number of systems
# Reference variables from main variables.tf file
# If you prefer to add different IP as source, change 'public_ip' variable to match
locals {
  public_ip = jsondecode(data.http.public_IP.body).ip
  config_file = yamldecode(file(var.ci_config_file))
}

############################################################
# Networking Setup - Internal
############################################################

# Define primary network range (10.0.0.0/16)
resource "azurerm_virtual_network" "main" {
  depends_on = [azurerm_resource_group.resourcegroup]
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.region
  resource_group_name = var.resource_group
}

# Define LAN for Cloud-Investigate server
resource "azurerm_subnet" "servers" {
  depends_on = [azurerm_resource_group.resourcegroup]
  name                 = "servers"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.server_subnet_cidr]
}

############################################################
# Networking Setup - External
############################################################
resource "azurerm_public_ip" "server" {
  depends_on = [azurerm_resource_group.resourcegroup]
  name                    = "${var.prefix}-ingress"
  location                = var.region
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
}

############################################################
# Firewall Rule Setup
############################################################

resource "azurerm_network_security_group" "windows" {
  depends_on = [azurerm_resource_group.resourcegroup]
  name                = "windows-nsg"
  location            = var.region
  resource_group_name = var.resource_group

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Allow-WinRM"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-WinRM-secure"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SMB"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "445"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Allow-SFTP"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${local.public_ip}/32"
    destination_address_prefix = "*"
  }
  
}

############################################################
# Server Resource
############################################################

# Create IP address space and interface for our forensic server
resource "azurerm_network_interface" "server" {
    depends_on = [azurerm_resource_group.resourcegroup]
    name                = "${var.prefix}-nic"
    location            = var.region
    resource_group_name = var.resource_group

    ip_configuration {
        name                          = "server-static"
        subnet_id                     = azurerm_subnet.servers.id
        private_ip_address_allocation = "Static"
        private_ip_address = cidrhost(var.server_subnet_cidr, 10)
        public_ip_address_id = azurerm_public_ip.server.id
    }
}

# Associate IP and Security Group with our DC
resource "azurerm_network_interface_security_group_association" "forensicserver" {
     depends_on = [azurerm_resource_group.resourcegroup]
     network_interface_id      = azurerm_network_interface.server.id
     network_security_group_id = azurerm_network_security_group.windows.id
}

# Create a server
resource "azurerm_virtual_machine" "forensicserver" {
        
      depends_on = [azurerm_resource_group.resourcegroup]
      
      name                  = "CloudInvestigate-Server"
      location              = var.region
      resource_group_name   = var.resource_group
      network_interface_ids = [azurerm_network_interface.server.id]
      vm_size               = var.server_size
       
      # Apply tag to server
      tags = {
       kind = "CloudInvestigate-Server"
      }
      
      # Delete the OS disk automatically when deleting the VM
      delete_os_disk_on_termination = true

      # Delete data disks automatically when deleting the VM
      delete_data_disks_on_termination = true

      storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = var.server_os
        sku       = var.server_SKU
        version   = "latest"
      }
      storage_os_disk {
        name              = "os-disk"
        caching           = "None"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = var.disk_size
      }
      os_profile {
        computer_name  = local.config_file.server_name
        admin_username = local.config_file.local_admin_credentials.username
        admin_password = local.config_file.local_admin_credentials.password
      }
      os_profile_windows_config {
          provision_vm_agent = true
          enable_automatic_upgrades = false
          timezone = "Central European Standard Time"
          winrm {
            protocol = "HTTP"
          }
      }
      
    # Format partition and install chocoladey with WSL so we can install remaining tools
    # This will block execution of other installers until chocoladey install is complete
    # The order of operation is important here so PATH variables are aligned 
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 120; /bin/bash -c 'ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook server.yml -t baseline,diskpart,chocoladey'"
    }
    
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 120; /bin/bash -c 'ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook server.yml -t wsl2'"
    }
}

resource "null_resource" "independent-tools-install" {
    depends_on = [azurerm_resource_group.resourcegroup, azurerm_virtual_machine.forensicserver]
    # Provision tools in the background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 700; /bin/bash -c 'ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook server.yml -t tools'"
    }   
}

resource "null_resource" "independent-kape-install" {
    depends_on = [azurerm_resource_group.resourcegroup, azurerm_virtual_machine.forensicserver]
    # Provision kape in the background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 120; /bin/bash -c 'ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook server.yml -t kape'"
    }   
}

resource "null_resource" "independent-sysmon-install" {
    depends_on = [azurerm_resource_group.resourcegroup, azurerm_virtual_machine.forensicserver]
    # Provision sysmon and monitoring in the background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 180; /bin/bash -c 'ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook server.yml -t sysmon,monitoring'"
    }   
}

resource "null_resource" "independent-autopsy-install" {
    depends_on = [azurerm_resource_group.resourcegroup, azurerm_virtual_machine.forensicserver]
    # Provision autopsy in the background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 90; /bin/bash -c 'ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook server.yml -t autopsy'"
    }   
}



############################################################
# Outputs
############################################################

output "printout" {
  value = <<EOF

Network Setup:
Cloud Investigate Server IP = ${azurerm_public_ip.server.ip_address}

Credentials:
Local Administrator: 
     Username: ${local.config_file.local_admin_credentials.username}
     Password: ${local.config_file.local_admin_credentials.password}

RDP to Cloud Investigate server: 
xfreerdp /v:${azurerm_public_ip.server.ip_address} /u:${local.config_file.local_admin_credentials.username} '/p:${local.config_file.local_admin_credentials.password}' +clipboard /cert-ignore


EOF
}