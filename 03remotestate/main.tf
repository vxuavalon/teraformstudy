 provider "azurerm" {
  version = "2.9.0"
  features{}
}
resource "azurerm_resource_group" "rg" {
    name = "terrastatetest"
    location = "eastus"
    tags = {
        Environment = "Terraform Demo"
    }
}
