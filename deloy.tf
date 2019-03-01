provider "azurerm" {
   subscription_id = "0dad996d-9b9f-45e8-b4ae-5f3131339340"
  # client_id       = "..."
  # client_secret   = "..."
  tenant_id       = "de08c407-19b9-427d-9fe8-edf254300ca7"
}

resource "azurerm_resource_group" "helloworld" {
  name     = "Development"
  location = "centralus"
}

resource "azurerm_storage_account" "helloworld" {
  name                     = "helloworldsa"
  resource_group_name      = "${azurerm_resource_group.helloworld.name}"
  location                 = "${azurerm_resource_group.helloworld.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "helloworld" {
  name                = "azure-functions-helloworld-service-plan"
  location            = "${azurerm_resource_group.helloworld.location}"
  resource_group_name = "${azurerm_resource_group.helloworld.name}"

  sku {
    tier = "Standard"
    size = "F1"
  }
}

resource "azurerm_function_app" "helloworld" {
  name                      = "test-azure-functions-cog-elan"
  location                  = "${azurerm_resource_group.helloworld.location}"
  resource_group_name       = "${azurerm_resource_group.helloworld.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.helloworld.id}"
  storage_connection_string = "${azurerm_storage_account.helloworld.primary_connection_string}"
  version = "2"

    provisioner "local-exec" {
    command = "${join("",list("az functionapp deployment source config ", " --repo-url 'https://github.com/svelango/TerraForm' --branch master --name ",azurerm_function_app.helloworld.name, " --resource-group ", azurerm_resource_group.helloworld.name) )}"

  }


    provisioner "local-exec" {
    command = "${join("",list("az functionapp deployment source sync --name ",azurerm_function_app.helloworld.name, " --resource-group ", azurerm_resource_group.helloworld.name)) }"
  }
}