
# Generate a random integer to create a globally unique name
/*resource "random_integer" "ri" {
  min = 10000
  max = 99999
}*/


/*resource "azurerm_resource_group" "rg1" {
  name     = "myResourceGroup-${random_integer.ri.result}"
  location = "westeurope"
}*/

resource "azurerm_virtual_network" "vnet1" {
  name                = "myVNet-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.21.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "myAGSubnet-${random_integer.ri.result}"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.21.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "myBackendSubnet-${random_integer.ri.result}"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.21.1.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_public_ip" "pip1" {
  name                = "myAGPublicIPAddress-1-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label = "webapp1-81772"
}

resource "azurerm_public_ip" "pip2" {
  name                = "myAGPublicIPAddress-2-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label = "webapp2-81772"
}



resource "azurerm_application_gateway" "network" {
  name                = "myAppGateway-${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  
  
  /*disable_bgp_route_propagation = false #trying to solve the routing problem by define the route and the priority

route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }*/

  sku {           #check which requirement you need to scale your sku
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1    #change capacity because of low requirement
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip1.id
  }

/*frontend_ip_configuration { #geht nicht mehr als ein ip frontend
    name                 = "frontendpip-2"
    public_ip_address_id = azurerm_public_ip.pip2.id
  }*/

  backend_address_pool {
    name = var.backend_address_pool_name
    ip_addresses = []
    fqdns = [
      "webapp-81772.azurewebsites.net",        
    ]
  }

  backend_address_pool {
    name = "webapp2"
    ip_addresses = []
    fqdns = [
      "webapp2-81772.azurewebsites.net",        
    ]
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    host_name             = "my-test-81772.westeurope.cloudapp.azure.com"
    pick_host_name_from_backend_address = false
    probe_name            = "myhealth"
    trusted_root_certificate_names = []
  }

  probe {
    host                  = "webapp-81772.azurewebsites.net"
    interval              = 10
    #minimum_servers       = 0
    name                  = "myhealth"
    path                  = "/"
    #pick_host_name_from_backend_http_settings = false
    #port                  = 0
    protocol              = "Http"
    timeout               = 5
    unhealthy_threshold   = 3

    match {
      status_code = [
        "200-399",
      ]
      }
    }    
  backend_http_settings {
    name                  = "webapp-2"
    cookie_based_affinity = "Disabled"
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    host_name             = "webapp2-81772.azurewebsites.net"
    pick_host_name_from_backend_address = false
    probe_name            = "myhealth-2"
    trusted_root_certificate_names = []
  }

  probe {
    host                  = "webapp2-81772.azurewebsites.net"
    interval              = 10
    #minimum_servers       = 0
    name                  = "myhealth-2"
    path                  = "/"
    #pick_host_name_from_backend_http_settings = false
    #port                  = 0
    protocol              = "Http"
    timeout               = 5
    unhealthy_threshold   = 3

    match {
      status_code = [
        "200-399",
      ]
      }
    }    

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
    host_names = [ "my-test-81772.westeurope.cloudapp.azure.com" ]
  }

  http_listener {
    name                           = "listener-2"
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
    host_names = [ "webapp2-81772.azurewebsites.net" ]
  }

  request_routing_rule {
    name                       = "webapprouting" #var.request_routing_rule_name
    rule_type                  = "PathBasedRouting"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 10
    url_path_map_name          = "webapprouting"
  }

request_routing_rule {
    name                       = "webapprouting2" #var.request_routing_rule_name
    rule_type                  = "PathBasedRouting"
    http_listener_name         = "listener-2"
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 11
    url_path_map_name          = "webapprouting2"
  }
  url_path_map {
    default_backend_address_pool_name = "myBackendPool"
    default_backend_http_settings_name = "myHTTPsetting"
    name = "webapprouting"
    path_rule {
      backend_address_pool_name = var.backend_address_pool_name
      backend_http_settings_name = "myHTTPsetting"
      name = "webapp1"
      paths = [
        "/*",
      ]
    }
  }
   url_path_map {
    default_backend_address_pool_name = "webapp2"
    default_backend_http_settings_name = "webapp-2"
    name = "webapprouting2"
    path_rule {
      backend_address_pool_name = var.backend_address_pool_name
      backend_http_settings_name = "myHTTPsetting"
      name = "webapp2"
      paths = [
        "/webapp2",
      ]
    }
  }
}
resource "random_password" "password" {
  length = 16
  special = true
  lower = true
  upper = true
  numeric = true
}


/*resource "azurerm_network_interface" "nic" {
  count = 2
  name                = "nic-${count.index+1}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "nic-ipconfig-${count.index+1}"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc01" {
  count = 2
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index+1}"
  #backend_address_pool_id = azurerm_application_gateway.network.backend_address_pool
  backend_address_pool_id = azurerm_application_gateway.network.id
}*/

/*resource "azurerm_windows_virtual_machine" "vm" {
  count = 2
  name                = "myVM${count.index+1}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_DS1_v2"
  admin_username      = "azureadmin"
  admin_password      = random_password.password.result

  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm-extensions" {
  count = 2
  name                 = "vm${count.index+1}-ext"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.htm\" -Value $($env:computername)"
    }
SETTINGS

}*/