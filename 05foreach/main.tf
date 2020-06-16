provider "azurerm" {
  version = "2.9.0"
  features{}
}


#Azure Generic vNet Module
resource "azurerm_resource_group" "MyResource" {
   name = var.resource_group_name
   location = "eastus"
}


resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.MyResource.name
  location            = azurerm_resource_group.MyResource.location
  address_space       = [var.address_space]
  dns_servers         = var.dns_servers
  tags                = var.tags
}

resource "azurerm_subnet" "subnet" {
  # count                = length(var.subnet_names)
  # name                 = var.subnet_names[count.index]
  # resource_group_name  = data.azurerm_resource_group.network.name
  # address_prefixes     = [var.subnet_prefixes[count.index]]
  # virtual_network_name = azurerm_virtual_network.vnet.name
   for_each = var.subnet
   name= each.key
   resource_group_name  = azurerm_resource_group.MyResource.name
   address_prefixes = [each.value]
   virtual_network_name = azurerm_virtual_network.vnet.name

}
