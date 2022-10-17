## Table of Contents
1. [General Info](#general-info)
2. [Installation](#installation)
3. [Infrastructure](#infrastructure)

### General Info
***
Create a Terraform Script with a Azure AppService with a APIGateway to secure network connectivity. Through a terraform apply, the  script execute and build a resourcegroup, VNet, 2 Appservice with 2 different paths and a APIGateway. 



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

$ az login
$ terraform init
$ terraform plan
$ terraform apply

Check your Azure subscribtion
```
## Infrastructure
***

myResourceGroup-81772.png

***
How to solve the unhealthy backend-status?
-> The important steps is to check if the right FQNS are adressed in the backend_address_pool, this could be a litte chaotic if you have to or more services. 
-> At the probe section check the host names, they should be the same as the one in the backend_address_pool. 
The timeout section should be 30 or over. If the timeout is set on 6 or lower there is no time to check the response and get a healthy status (200)
->http_listener should have the same hostnames as the backend and the probe.
Important Note: Every Host-name should be the same (for each appService for example: AppService 1 -> all host name config for AppService 1 should be the same) 
                For AppService 2 the same example.
