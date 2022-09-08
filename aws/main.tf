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

# AWS Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/aws"
      version = "~> 4.15"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = "${var.region}"
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
  config_file = yamldecode(file(var.system_config_file))
}


############################################################
# Networking Setup
############################################################

# Define primary network range (10.0.0.0/16)
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
   Name = "${var.prefix}-network"
  }
}

# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
   Name = "${var.prefix}-gateway"
  }
}

# Define Route Table (access everywhere)
resource "aws_route_table" "main" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = "${aws_internet_gateway.gw.id}" 
    }

  tags = {
   Name = "${var.prefix}-route-table"
  }
}

# Define LAN for Windows Servers
resource "aws_subnet" "windows-servers" {
  depends_on = [aws_internet_gateway.gw]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.windows_server_subnet_cidr
  map_public_ip_on_launch = true
  
  availability_zone = var.region
  tags = {
   Name = "${var.prefix}-windows-server-lan"
  }
}

# Associate routing table with subnets
resource "aws_route_table_association" "winserv"{
    subnet_id = "${aws_subnet.windows-servers.id}"
    route_table_id = "${aws_route_table.main.id}"
}

############################################################
# Firewall Rule Setup
############################################################
resource "aws_security_group" "firewallsetup" {
    vpc_id = "${aws_vpc.main.id}"
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 3389
        to_port = 3389
        protocol = "tcp"
        cidr_blocks = ["${local.public_ip}/32"]
    }
    ingress {
        from_port = 445
        to_port = 445
        protocol = "tcp"
        cidr_blocks = ["${local.public_ip}/32"]
    }
    ingress {
        from_port = 5985
        to_port = 5985
        protocol = "tcp"
        cidr_blocks = ["${local.public_ip}/32"]
    }
    ingress {
        from_port = 5986
        to_port = 5986
        protocol = "tcp"
        cidr_blocks = ["${local.public_ip}/32"]
    }
	
	ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${local.public_ip}/32"]
    }
    
  tags = {
    Name = "${var.prefix}-firewall"
  }
}

############################################################
# Key Creation & Credential Setup
############################################################

resource "tls_private_key" "deploykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${var.prefix}-deploykey"
  public_key = tls_private_key.deploykey.public_key_openssh
}

# A lot of this repeats what baseline script does.
data "template_file" "win_creds" {
template = <<EOF
<script>
netsh advfirewall set allprofiles state off
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
</script>
<powershell>
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableLUA -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\Policies\System -Name ConsentPromptBehaviorAdmin -PropertyType DWord -Value 0 -Force
Enable-PSRemoting -Force
$accountb = [ADSI]("WinNT://localhost/Administrator,user")
$accountb.psbase.invoke("setpassword","${local.config_file.local_admin_credentials.password}")
Rename-LocalUser -Name "Administrator" -NewName "prime"
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:SystemDrive\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -nop -File $file
Enable-PSRemoting -Force
Rename-Computer -NewName "${local.config_file.server_name}"
cmd.exe /c winrm set winrm/config @{MaxTimeoutms="350000"}
cmd.exe /c winrm set winrm/config/service @{MaxConcurrentOperationsPerUser="500"}
cmd.exe /c winrm set winrm/config/Service @{MaxConcurrentOperations="500"}
cmd.exe /c winrm set winrm/config/service @{AllowUnencrypted="true"}
cmd.exe /c winrm set winrm/config/winrs @{MaxShellsPerUser="400"}
cmd.exe /c winrm set winrm/config/winrs @{MaxConcurrentUsers="300"}
cmd.exe /c winrm set winrm/config/winrs @{MaxMemoryPerShellMB="512"}
</powershell>
<persist>false</persist>
EOF 
}

############################################################
# Windows Server Resources
############################################################

resource "aws_instance" "windows-servers" {
  depends_on                  = [aws_internet_gateway.gw, aws_key_pair.generated_key,aws_security_group.firewallsetup]
  ami                         = var.server_AMI
  availability_zone           = var.region
  instance_type               = var.server_size
  monitoring                  = true
  vpc_security_group_ids      = [aws_security_group.firewallsetup.id]
  subnet_id                   = "${aws_subnet.windows-servers.id}"
  associate_public_ip_address = true
  get_password_data           = true
  key_name                    = aws_key_pair.generated_key.key_name
  user_data                   = data.template_file.win_creds.rendered
  
  root_block_device {
    volume_size = var.disk_size
    volume_type = "standard"
    delete_on_termination = "true"
  }
     
  tags = {
    Name  = var.server_os
    amireference = var.server_AMI
    kind = "CloudInvestigate-Server"
    os = var.server_os
  }
  
  
    # This will block execution of other installers until chocoladey install is complete
    # The order of operation is important here so PATH variables are aligned 
    provisioner "local-exec" {
    working_dir = "${path.root}/../ansible/"
    interpreter = ["/bin/bash", "-c"]
    command = "sleep 120; ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook ${path.root}/server.yml -i \"${aws_instance.windows-servers.public_ip},\" -t baseline,chocoladey"
    }
    
    provisioner "local-exec" {
    working_dir = "${path.root}/../ansible/"
    interpreter = ["/bin/bash", "-c"]
    command = "sleep 120; ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook ${path.root}/server.yml -i \"${aws_instance.windows-servers.public_ip},\" -t wsl2"
    }
}


resource "null_resource" "independent-tools-install" {
    depends_on = [aws_instance.windows-servers]
    # Provision tools in background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 700; ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook ${path.root}/server.yml -i \"${aws_instance.windows-servers.public_ip},\" -t tools"
    }   
}

resource "null_resource" "independent-kape-install" {
    depends_on = [aws_instance.windows-servers]
    # Provision kape in background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 60; ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook ${path.root}/server.yml -i \"${aws_instance.windows-servers.public_ip},\" -t kape"
    }   
}

resource "null_resource" "independent-sysmon-install" {
    depends_on = [aws_instance.windows-servers]
    # Provision sysmon in background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 150; ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook ${path.root}/server.yml -i \"${aws_instance.windows-servers.public_ip},\" -t sysmon,monitoring "
    }   
}

resource "null_resource" "independent-autopsy-install" {
    depends_on = [aws_instance.windows-servers]
    # Provision autopsy in background
    provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.root}/../ansible/"
    command = "sleep 90; ANSIBLE_CONFIG=${path.root}/ansible.cfg ansible-playbook ${path.root}/server.yml -i \"${aws_instance.windows-servers.public_ip},\" -t autopsy"
    }   
}

############################################################
# Outputs
############################################################

output "printout" {
depends_on = [aws_internet_gateway.gw, aws_key_pair.generated_key,aws_security_group.firewallsetup,aws_instance.windows-servers]
value = <<EOF

Network Setup:
Cloud Investigate Server IP = ${aws_instance.windows-servers.public_ip}

Credentials: 
Local Administrator:  
    Username: ${local.config_file.local_admin_credentials.username} 
    Password: ${local.config_file.local_admin_credentials.password}
    
RDP to Cloud Investigate server: 
xfreerdp /v:${aws_instance.windows-servers.public_ip} /u:Administrator '/p:${local.config_file.local_admin_credentials.password}' +clipboard /cert-ignore

EOF
}