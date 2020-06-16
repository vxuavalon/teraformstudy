provider "azurerm" {
  version = "2.9.0"
  features{}
}

variable "bootdiag_storage" {
  type = bool
  description = "Enter the name of the boot diagnostic storage account if one is desired"
  default = true
}

resource "azurerm_resource_group" "MyResource" {
   name = "example-name"
   location = "West US"

}   

resource "azurerm_storage_account" "MyResourceName" {
   count = var.bootdiag_storage ? 1 : 0
   name = "az20200701"
   resource_group_name = azurerm_resource_group.MyResource.name
   location = azurerm_resource_group.MyResource.location
   account_tier = "Standard"
   account_replication_type = "GRS"
}