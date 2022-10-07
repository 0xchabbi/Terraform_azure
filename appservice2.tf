# Create the Linux App Service Plan
/*resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp2-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  os_type             = "Linux"
  sku_name            = "F1"
}*/

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp2" {
  name                  = "webapp2-${random_integer.ri.result}"
  location              = azurerm_resource_group.rg1.location
  resource_group_name   = azurerm_resource_group.rg1.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  virtual_network_subnet_id = "/subscriptions/8fdfcd42-cb6a-4f09-bd1d-984a332c84b1/resourceGroups/myResourceGroup-31905/providers/Microsoft.Network/virtualNetworks/myVNet-31905/subnets/myBackendSubnet-31905"
  site_config {             #that solves the error statuscode=0
    minimum_tls_version = "1.2"
    always_on           = false
    vnet_route_all_enabled = true
    #health_check_path = "/healhz"

    application_stack {
      docker_image = "docker.io/bitnami/nginx"
      docker_image_tag = "latest"
    }
  }
app_settings = {
WEBSITES_PORT = "8080"
}
}