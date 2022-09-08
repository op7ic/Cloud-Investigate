###############################################################
# Author      : Jerzy 'Yuri' Kramarz (op7ic)                  #
# Version     : 1.0                                           #
# Type        : Terraform/Ansible                             #
# Description : Cloud-Investigate. See README.md for details  # 
# License     : See LICENSE for details                       #   
###############################################################


############################################################
# Defualt config for various settings such as LAN segments, location of domain config file etc.
############################################################

variable "ci_config_file" {
    description = "Path to the primary configuration file for Server"
    default = "../config/os-setup.yml"
}

variable "server_subnet_cidr" {
    description = "CIDR to use for the server hosting"
    default = "10.0.10.0/24"
}

variable "region" {
    description = "Azure region in which resources should be created. See https://azure.microsoft.com/en-us/global-infrastructure/locations/"
    default = "West Europe"
}

variable "resource_group" {
    description = "Resource group in which resources should be created"
    default = "cloud-investigate-lab"
}

variable "prefix" {
    description = "prefix for dynamic hosts"
    default = "ci-lab"
}

############################################################
# Host Sizing. See https://docs.microsoft.com/en-us/azure/cloud-services/cloud-services-sizes-specs for details
############################################################

variable "server_size" {
    description = "Size of the Domain Controller VM"
    default = "Standard_D2_v2"
}

############################################################
# Host Types to run Windows Server on. 
############################################################

variable "server_os" {
    description = "DC Operating System"
    default = "WindowsServer"
}

variable "server_SKU" {
    description = "Server SKU"
    default = "2022-Datacenter"
}

variable "disk_size" {
    description = "Size of the disk used for base OS. Default 4095GB"
    default = "4095"
}



