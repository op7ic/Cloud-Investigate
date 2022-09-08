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

variable "system_config_file" {
    description = "Path to the primary configuration file for deployment"
    default = "../config/os-setup.yml"
}

variable "windows_server_subnet_cidr" {
    description = "CIDR to use for hosting Windows Servers"
    default = "10.0.10.0/24"
}

variable "region" {
    description = "AWS region in which resources should be created. See https://aws.amazon.com/about-aws/global-infrastructure/regions_az/"
    default = "us-east-1a" 
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
# Host Types to run Windows Server on. 
############################################################

variable "server_os" {
    description = "DC Operating System"
    default = "Windows_Server-2022-English-Full-Base-2022.05.11"
}

variable "server_AMI" {
    description = "Server SKU"
    default = "ami-0e2c8caa770b20b08"
}

variable "server_size" {
    description = "Server size"
    default = "t2.xlarge"
}

variable "disk_size" {
    description = "Size of the disk used for base OS. Default 1024GB"
    default = "1024"
}

