# Purpose

This project contains a set of **Terraform** and **Ansible** scripts for AWS and Azure to create a rapid deployment forensic system. The goal of this project is to provide red/blue teams, developers and IT teams with the ability to deploy a quick pre-configured Windows-based system to perform basic forensic investigation on various artifacts with minimal overhead in cloud that can be easily created and removed after investigation is concluded.

---
# Use cases

* Rapid forensic investigation of a VMDK or triage images which can be downloaded directly onto the VM
* Basic analysis of malware samples on a throwaway system

---
# Tools included

A global YAML config file, [Azure os-setup.yml](azure/config/os-setup.yml) or [AWS os-setup.yml](aws/config/os-setup.yml), sets the versions of the tools and specific URLs which should be downloaded.

The following tools are currently deployed using this setup:

* Autopsy
* Sysinternals
* Volatility (2 and 3)
* Megatools https://community.chocolatey.org/packages/megatools/
* Aresnal Image Mouter (https://mega.nz/file/vsJVGI5D#cyBkjLKIxskTS3q5J0pW19swgykBwK6_ofzjJOmg2MA)
* Arsenal Registry Recon (https://mega.nz/file/PwJGXTQZ#Py3NGbvkkJzeEAoCJ9aghdyVuP1Augfa5Hz-jRATNEs)
* Arsenal Hive Recon (https://mega.nz/file/GxpD2CIa#ADTUWZrX328ijGXNTfe6sxKLkNMkXsu6w3s7b2EdZ8s)
* Arsenal Hibernation Recon (https://mega.nz/file/Kl4AzBTI#gEWZCXQPzVjyuCwfMVvePVsAwl3_IZ0LRpeY0AkGL-c)
* Arsenal HIBN Recon (https://mega.nz/file/i04RjYJI#yqyrgECgUjKxwGSCsvx-fhvwkICGTr2z7OihTJoeWys)
* Arsenal ODC Recon (https://mega.nz/file/604lWb4Z#Tn3ePIlMaGOSmTfuCMKaEeLRyTU0S4uCekZQJzKttCQ)
* Windows WSL with Ubuntu
* FTK Imager
* Fireeye Redline (https://fireeye.market/apps/211364) - https://www.fireeye.com/content/dam/fireeye-www/services/freeware/sdl-redline.zip
* Fireeye Memoryze (https://fireeye.market/apps/211368) - https://www.fireeye.com/content/dam/fireeye-www/services/freeware/sdl-memoryze.zip
* Fireeye Highlighter (https://fireeye.market/apps/211376) - https://www.fireeye.com/content/dam/fireeye-www/services/freeware/sdl-highlighter.zip
* Notepad++ 
* Sysmon (installed for your own records)
* Nirsoft Archive (https://www.nirsoft.net/utils/index.html)
* NirLauncher Package (https://launcher.nirsoft.net/downloads/index.html)
* 7zip
* Winrar
* EricZimmerman Tools (https://ericzimmerman.github.io/#!index.md)
* PowerForensic (https://github.com/Invoke-IR/PowerForensics)
* Velociraptor 
* Kape
* GRR (https://github.com/google/grr)
* LogonTracer (https://github.com/JPCERTCC/LogonTracer)
* Log2Timeline
* Chocolatey package manager
* Burp Community Edition (https://portswigger-cdn.net/burp/releases/download?product=community&version=2022.7.1&type=WindowsX64)
* WinDBG (with symbols)
* 

---
# Prerequisites for Azure

A number of features need to be installed on your system in order to use this setup. Please follow steps below to ensure that CLI and API required by Azure/AWS are fully functional before deployment.

```
# Step 1 - Install Azure CLI. More details on https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Step 2 - Install Terraform. More details on https://learn.hashicorp.com/tutorials/terraform/install-cli
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Step 3 - Install Ansible. More details on https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install ansible

# Step 4 - Finally install python and various packages needed for remote connections and other activities
sudo apt install python3 python3-pip
pip3 install pywinrm requests msrest msrestazure azure-cli
```

# Prerequisites for AWS
```
# Step 1 - Install AWS CLI. More details on https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Step 2 - Install Terraform. More details on https://learn.hashicorp.com/tutorials/terraform/install-cli
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Step 3 - Install Ansible. More details on https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt update
sudo apt install ansible

# Step 4 - Finally install python and various packages needed for remote connections and other activities
sudo apt install python3 python3-pip pywinrm requests
```

# Building and Deploying Cloud Investigate system

Once all the [prerequisites](#prerequisites-for-azure) are installed, perform the following series of steps:
```
# Log in to Azure or AWS from command line to ensure that the access token is valid or credentials are added for AWS:
az login or use aws configure 

# Clone Repository and move to BlueTeam.Lab folder:
git clone https://github.com/op7ic/Cloud-Investigate.git
cd Cloud-Investigate/azure # or cd Cloud-Investigate/aws

# Initialize Terraform and begin planning:
terraform init && terraform plan

# Create your lab using the following command: 
terraform apply -auto-approve

# Once done, destroy your lab using the following command:
terraform destroy -auto-approve

# If you would like to time the execution use the following command:
start_time=`date +%s` && terraform apply -auto-approve && end_time=`date +%s` && echo execution time was `expr $end_time - $start_time` s
```

# Deploying different OS versions or limiting the number of created hosts

A global YAML config file, [Azure os-setup.yml](azure/config/os-setup.yml) or [AWS os-setup.yml](aws/config/os-setup.yml), sets the type of operating system, SKU, AMI and VM size used for the deployment of the VMs. 

Commands ```az vm image list``` (Azure) or ```aws ec2 describe-images``` (AWS) can be used to identify various OS versions so that global operating system file ([Azure os-setup.yml](azure/config/os-setup.yml) or [AWS os-setup.yml](aws/config/os-setup.yml) can be modified with the correspodning SKU or AMI. Examples of commands helping to identify specific AMI/SKU can be found below.

```
# Azure

# List all Windows workstation SKUs and images
az vm image list --publisher MicrosoftWindowsDesktop --all -o table
# List all Windows server SKUs and images
az vm image list --publisher WindowsServer --all -o table
# List all Debian server SKUs and images
az vm image list --publisher Debian --all -o table
# List all RedHat server SKUs and images
az vm image list --publisher RedHat --all -o table
# List all Canonical server SKUs and images
az vm image list --publisher Canonical --all -o table

# AWS

# List all Windows server AMIs
aws ec2 describe-images --owners amazon --filters Name=root-device-type,Values=ebs Name=architecture,Values=x86_64 Name=name,Values=*Windows_Server*English*Base* --query 'Images[].{ID:ImageId,Name:Name,Created:CreationDate}' --region us-east-1
```

Please note that Windows desktop (i.e. Windows 10/11) is currently not supported on AWS EC2 without a custom AMI, so the AWS version of Cloud-Investigate does not support its deployment, as it relies on the pre-existing images. That said, [AWS os-setup.yml](aws/os-setup.yml) can be easily modified to include a reference to custom AMIs.

# Changing network ranges and deployment location

Location and network ranges can be set using global variables in [Azure variables.tf](azure/variables.tf) or the [AWS variables.tf](aws/variables.tf) file. A simple modification to runtime variables also allows to specify regions or network ranges as seen below:

```
# Use default options for Azure or AWS
terraform apply -auto-approve

# Use East US region to deploy the lab for Azure
terraform apply -auto-approve -var="region=East US"

# Use East US region to deploy the lab for AWS
terraform apply -auto-approve -var="region=us-east-1a"

# Use East US and change Windows Workstation or Server ranges for Azure
terraform apply -auto-approve -var="region=East US" -var="windows_server_subnet_cidr=10.0.0.0/24"

# Use East US and change Windows Workstation or Server ranges for AWS
terraform apply -auto-approve -var="region=us-east-1a" -var="windows_server_subnet_cidr=10.0.0.0/24"
```

---
# Firewall Configuration

The following table summarises a set of firewall rules applied across the Cloud Investigate enviroment in default configuration. Please modify the [azure main.tf](azure/main.tf) or [azure main.tf](aws/main.tf) file to add new firewall rules, as needed, in the **Firewall Rule Setup** section. 

| Rule Name | Network Security Group | Source Host | Source Port  | Destination Host | Destination Port |
| ------------- | ------------- |  ------------- |  ------------- |  ------------- |  ------------- |
| Allow-RDP  | windows-nsg  | [Your Public IP](https://ipinfo.io/json) | * | Windows Servers, Windows Desktops  | 3389 |  
| Allow-WinRM  | windows-nsg  | [Your Public IP](https://ipinfo.io/json) | * | PWindows Servers, Windows Desktops | 5985 |  
| Allow-WinRM-secure | windows-nsg  | [Your Public IP](https://ipinfo.io/json) | * | Windows Servers, Windows Desktops | 5986 |  
| Allow-SMB  | windows-nsg  | [Your Public IP](https://ipinfo.io/json) | * | Windows Servers, Windows Desktops | 445 |

Internally the following static IP ranges are used for this enviroment in the default configuration:

| Hosts  | Internal IP range | Notes | 
| ------------- | ------------- | ------------- |
| Windows Servers or Destkop | 10.0.10.0/24 | |


# Contributing

Contributions, fixes, and improvements can be submitted directly for this project as a GitHub issue or a pull request.

