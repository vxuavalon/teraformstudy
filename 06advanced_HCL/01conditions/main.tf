provider "azurerm" {
  version = "2.9.0"
  features{}
}

resource "azurerm_resource_group" "rg" {
  name = "rg-testcondittion"
  location = var.location !="" ? var.location : "eastus"
}
