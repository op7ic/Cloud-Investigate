# Purpose

This project contains a set of **Terraform** and **Ansible** scripts for **AWS** and **Azure** to create disposable in-cloud forensic system. The goal of this project is to provide blue teams with the ability to deploy a quick pre-configured Windows-based server to perform basic forensic investigation on various artifacts with minimal overhead. The system and data can be easily deleted after investigation is concluded.

---
# Use cases

* Rapid forensic investigation of a VMDK or triage images which can be downloaded directly onto the VM
* Basic analysis of malware and memory samples on a throwaway system

---
# Tools included

A global YAML config file, [os-setup.yml](config/os-setup.yml), sets the versions of the tools and specific URLs which should be downloaded.

The following tools are currently deployed in the default configuration of Cloud Investigate:

| Tool | Tool Location | Notes | 
| ------------- | ------------- | ------------- |
| [Sysinternals Suite](https://community.chocolatey.org/packages/sysinternals) | C:\Tools\SysinternalsSuite\ | Unzipped tool suite |
| [Aresnal Image Mouter](https://mega.nz/file/vsJVGI5D#cyBkjLKIxskTS3q5J0pW19swgykBwK6_ofzjJOmg2MA) | C:\Tools\ArsenalTools\ | Installer |
| [Arsenal Registry Recon](https://mega.nz/file/PwJGXTQZ#Py3NGbvkkJzeEAoCJ9aghdyVuP1Augfa5Hz-jRATNEs) | C:\Tools\ArsenalTools\  | Installer |
| [Arsenal Hive Recon](https://mega.nz/file/GxpD2CIa#ADTUWZrX328ijGXNTfe6sxKLkNMkXsu6w3s7b2EdZ8s) | C:\Tools\ArsenalTools\ | Installer |
| [Arsenal Hibernation Recon](https://mega.nz/file/Kl4AzBTI#gEWZCXQPzVjyuCwfMVvePVsAwl3_IZ0LRpeY0AkGL-c) | C:\Tools\ArsenalTools\ | Installer |
| [Arsenal HIBN Recon](https://mega.nz/file/i04RjYJI#yqyrgECgUjKxwGSCsvx-fhvwkICGTr2z7OihTJoeWys) | C:\Tools\ArsenalTools\ | Installer  |
| [Arsenal ODC Recon](https://mega.nz/file/604lWb4Z#Tn3ePIlMaGOSmTfuCMKaEeLRyTU0S4uCekZQJzKttCQ) | C:\Tools\ArsenalTools\ | Installer |
| [Burp Community Edition](https://portswigger-cdn.net/burp/releases/download?product=community&version=2022.7.1&type=WindowsX64) | C:\Program Files\BurpSuiteCommunity\ | Installed tool |
| [Fireeye Redline](https://fireeye.market/apps/211364) | C:\Tools\MandiantTools\ | Installer |
| [Fireeye Memoryze](https://fireeye.market/apps/211368) | C:\Tools\MandiantTools\ | Installer  |
| [Fireeye Highlighter](https://fireeye.market/apps/211376) | C:\Tools\MandiantTools\ | Installer  |
| [Velociraptor](https://docs.velociraptor.app/docs/) | C:\Tools\Velociraptor\ | Unzipped tool suite |
| [Kape](https://www.kroll.com/en/insights/publications/cyber/kroll-artifact-parser-extractor-kape) | C:\tools\KAPE\ | Unzipped tool suite |
| [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install) | N/A | WSL Version 1 installed |
| [Autopsy](https://www.autopsy.com/download/) | C:\Program Files\ | Installed tool |
| [Chocolatey](https://docs.chocolatey.org/en-us/) | C:\ProgramData\Chocolatey | Installed tool |
| [NirLauncher Package](https://community.chocolatey.org/packages/nirlauncher) | C:\tools\NirLauncher | Installed tool |
| [7zip](https://community.chocolatey.org/packages/7zip)|  C:\Program Files\7-Zip | Installed tool |
| [Winrar](https://community.chocolatey.org/packages/winrar) |  C:\ProgramData\Chocolatey | Installed tool |
| [Notepad++](https://community.chocolatey.org/packages/notepadplusplus) |  C:\Program Files\Notepad++ | Installed tool |
| [Megatools](https://community.chocolatey.org/packages/megatools/) |  C:\ProgramData\Chocolatey | Installed tool |
| [WinDBG](https://community.chocolatey.org/packages/windows-sdk-10-version-2004-windbg) |  C:\Program Files (x86)\Windows Kits\ | Installed tool |
| [WinSCP](https://community.chocolatey.org/packages/winscp) | C:\Program Files (x86)\WinSCP | Installed and added to PATH | 
| [EricZimmerman Tools](https://ericzimmerman.github.io/#!index.md) |  C:\tools\ericzimmermantools | Unzipped tool suite  |
| [wireshark](https://community.chocolatey.org/packages/wireshark) |  C:\Program Files\Wireshark | Installed and added to PATH | 
| [ext2fsd](https://community.chocolatey.org/packages/ext2fsd) |  C:\Program Files\Ext2Fsd | Installed and added to PATH | 
| [Firefox Browser](https://www.mozilla.org/en-US/firefox/new/) | C:\Program Files\Mozilla Firefox | Installed tool |
| [Chrome Browser](https://www.google.com/chrome/) | C:\Program Files\Google | Installed tool | 
| [Python3.10](https://community.chocolatey.org/packages/python) | C:\Python310 | Installed and added to PATH | 
| [Volatility2](https://community.chocolatey.org/packages/volatility) | C:\ProgramData\Chocolatey | Installed and added to PATH | 
| [radare2](https://community.chocolatey.org/packages/radare2) | C:\ProgramData\Chocolatey | Installed and added to PATH | 
| [qemu-img](https://community.chocolatey.org/packages/qemu-img) | C:\ProgramData\Chocolatey | Installed and added to PATH | 
| [qemu](https://community.chocolatey.org/packages/qemu) | C:\Program Files\qemu | Installed and added to PATH | 
| [sandboxie-plus](https://community.chocolatey.org/packages/sandboxie-plus) | C:\Program Files\Sandboxie-Plus | Installed tool | 
| [smartftp](https://community.chocolatey.org/packages/smartftp) | C:\Program Files\SmartFTP Client | Installed tool | 
| [Cygwin](https://community.chocolatey.org/packages/Cygwin) | C:\tools\Cygwin | Installed tool | 
| [kubernetes-cli](https://community.chocolatey.org/packages/kubernetes-cli) | C:\ProgramData\Chocolatey | Installed tool | 
| [putty](https://community.chocolatey.org/packages/putty) | C:\Program Files\PuTTY | Installed tool | 
| [yara](https://community.chocolatey.org/packages/yara) | C:\ProgramData\Chocolatey | Installed and added to PATH | 
| [powertoys](https://community.chocolatey.org/packages/powertoys) | C:\Program Files\PowerToys | Installed tool | 
| [virtualmachineconverter](https://community.chocolatey.org/packages/virtualmachineconverter) | C:\Program Files\Microsoft Virtual Machine Converter | Installed tool | 
| [HashCheck](https://community.chocolatey.org/packages/HashCheck) | C:\Program Files\HashCheck | Installed and added as menu option|  
| [Brim](https://github.com/brimdata/brim) | C:\Users\<user>\AppData\Local\Programs\brim\ | Installed tool |  
| [Plaso](https://github.com/log2timeline/plaso) | C:\tools\plaso | Source Code |
| [volatility3](https://github.com/volatilityfoundation/volatility3) | C:\tools\volatility3\ | Source Code |
| [SANS Sift packages (200+) ](https://www.sans.org/tools/sift-workstation/) | N/A | Installed inside of WSL during deployment. Note: Due to time it takes to deploy SIFT, the installation is left to run in the background in WSL. |
| [TOR Browser](https://community.chocolatey.org/packages/tor-browser) | C:\ProgramData\Chocolatey | Installed tool |
| [PassMark OSForensics](https://www.osforensics.com/download.html) | C:\Program Files\OSForensics | Installed tool | 
| [PassMark OSFMount](https://www.osforensics.com/tools/mount-disk-images.html) | C:\Program Files\OSFMount | Installed tool | 
| [PassMark VolatilityWorkbench](https://www.osforensics.com/tools/volatility-workbench.html) | C:\tools\passmark | Installer | 
| [Secure remove contex menu using sDelete64](https://www.tenforums.com/tutorials/124286-add-secure-delete-context-menu-windows-10-a.html) | C:\tools\sdelete.reg | Installed tool | 

The following KAPE plugins/addones were also added:

| Tool | Tool Location | Notes | 
| ------------- | ------------- | ------------- |
| [KAPE-EZToolsAncillaryUpdater](https://raw.githubusercontent.com/AndrewRathbun/KAPE-EZToolsAncillaryUpdater/main/KAPE-EZToolsAncillaryUpdater.ps1) | C:\tools\KAPE\ | KAPE updater |
| [reg_hunter](https://github.com/theflakes/reg_hunter/releases/download/0.6.0/reg_hunter-64.exe) | C:\tools\KAPE\Modules\bin\ | reg_hunter plugin |
| [SEPparser](https://github.com/Beercow/SEPparser/raw/master/bin/SEPparser.exe) | C:\tools\KAPE\Modules\bin\ | SEPparser plugin |
| [srum_dump](https://github.com/MarkBaggett/srum-dump/raw/python3/srum_dump_csv.exe) | C:\tools\KAPE\Modules\bin\ | srum_dump plugin |
| [OneDriveExplorer](https://github.com/Beercow/OneDriveExplorer/releases/download/v2022.06.17/OneDriveExplorer.exe) | C:\tools\KAPE\Modules\bin\ | OneDriveExplorer plugin |
| [hindsight](https://github.com/obsidianforensics/hindsight/releases/download/v2021.12/hindsight.exe) | C:\tools\KAPE\Modules\bin\ | hindsight plugin |
| [dhparser](https://github.com/jklepsercyber/defender-detectionhistory-parser/blob/main/dhparser.exe) | C:\tools\KAPE\Modules\bin\ | dhparser plugin |
| [CCMRUAFinder_RecentlyUsedApps](https://github.com/esecrpm/WMI_Forensics/raw/master/CCM_RUA_Finder.exe) | C:\tools\KAPE\Modules\bin\ | CCMRUAFinder_RecentlyUsedApps plugin |
| [BMC-Tools_RDPBitmapCacheParse](https://github.com/dingtoffee/bmc-tools/blob/master/dist/bmc-tools.exe) | C:\tools\KAPE\Modules\bin\ | BMC-Tools_RDPBitmapCacheParse plugin |
| [sigcheck](https://live.sysinternals.com/sigcheck64.exe) | C:\tools\KAPE\Modules\bin\ | sigcheck plugin |
| [INDXRipper](https://github.com/harelsegev/INDXRipper/releases/download/v5.2.6/INDXRipper-5.2.6-py3.9-amd64.zip) | C:\tools\KAPE\Modules\bin\ | INDXRipper plugin |
| [Chainsaw](https://github.com/WithSecureLabs/chainsaw/releases/download/v2.0.0-beta.5/chainsaw_all_platforms+rules+examples.zip) | C:\tools\KAPE\Modules\bin\ | Chainsaw plugin |
| [hayabusa](https://github.com/Yamato-Security/hayabusa/releases/download/v1.5.0/hayabusa-1.5.0-all-windows.zip) | C:\tools\KAPE\Modules\bin\ | hayabusa plugin |
| [LevelDBDumper](https://github.com/mdawsonuk/LevelDBDumper/releases/download/v2.0.2/LevelDBDumper.exe) | C:\tools\KAPE\Modules\bin\ | LevelDBDumper plugin |
| [McAfeeStinger](https://downloadcenter.mcafee.com/products/mcafee-avert/stinger/stinger32.exe) | C:\tools\KAPE\Modules\bin\ | McAfeeStinger plugin |
| [Kaspersky_TDSSKiller](http://media.kaspersky.com/utilities/VirusUtilities/EN/tdsskiller.exe) | C:\tools\KAPE\Modules\bin\ | Kaspersky_TDSSKiller plugin |
| [EvtxHussar](https://github.com/yarox24/EvtxHussar/releases/download/1.5/EvtxHussar1.5_windows_amd64.zip ) | C:\tools\KAPE\Modules\bin\ | EvtxHussar plugin |
| [Nirsoft Tools](https://www.nirsoft.net/) | C:\tools\KAPE\Modules\bin\ | Various Nirsoft plugins as defined by Kape files |
| [RegRipper](https://github.com/keydet89/RegRipper3.0/archive/refs/heads/master.zip) | C:\tools\KAPE\Modules\bin\ | RegRipper plugin |
| [TZWorks CAFAE](https://tzworks.com/prototypes/cafae/cafae64.v.0.75.win.zip) | C:\tools\KAPE\Modules\bin\ | TZWorks CAFAE plugin |
| [TZWorks evtwalk64](https://tzworks.com/prototypes/evtwalk/evtwalk64.v.0.59.win.zip) | C:\tools\KAPE\Modules\bin\ | TZWorks evtwalk64 plugin |
| [NTFS Log Tracker v1.7 CMD](https://drive.google.com/u/0/uc?id=12Xzp0GW9KqaejFrK7ewGYzKWNEjRgP1P&export=download) | C:\tools\KAPE\Modules\bin\ | NTFS Log Tracker v1.7 CMD plugin |
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
pip3 install pywinrm requests msrest msrestazure azure-cli requests-ntlm
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
sudo apt install python3 python3-pip pywinrm requests requests-ntlm
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
| Windows System | 10.0.10.0/24 | |


# Contributing

Contributions, fixes, and improvements can be submitted directly for this project as a GitHub issue or a pull request.

