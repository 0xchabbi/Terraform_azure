## Table of Contents
1. [General Info](#general-info)
2. [Installation](#installation)

### General Info
***
Create a Terraform Script with a Azure AppService with a APIGateway to secure network connectivity. Through a terraform apply, the  script execute and build a resourcegroup, VNet, Appservice and a APIGateway. 



## Installation
***
A little intro about the installation. 
```
Configure your environment

Create a free Azure subscription 
-> https://azure.microsoft.com/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio

Configure Terraform in your preferred environment
-> https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-bash
-> https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-cloud-shell-powershell
-> https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-bash
-> https://learn.microsoft.com/en-us/azure/developer/terraform/get-started-windows-powershell
-> https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started


$ git clone https://git.me2digital.com/b.chabbi/DemoSiemens.git
$ cd ./DemoSiemens

$az login
$terraform init
$terraform plan
$terraform apply

Check your Azure subscribtion
