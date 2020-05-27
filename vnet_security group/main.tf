provider "azurerm"{
    version = "=2.0.0"
    features{}
}

resource "azurerm_resource_group" "test" {
  name     = "my-resources"
  location = "East US"
}

module "vnet" {
  source              = "./modules/VNET"
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["subnet1", "subnet2", "subnet3"]

  nsg_ids = {
    subnet1 = module.network-security-group.network_security_group_id
  }


  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

module "network-security-group" {
  source                = "./modules/NSG"
  resource_group_name   = azurerm_resource_group.test.name
  security_group_name   = "nsg"
  source_address_prefix = ["10.0.3.0/24"]
  predefined_rules = [
    {
      name     = "SSH"
      priority = "500"
      access = "deny"
    },
    {
      name              = "LDAP"
      source_port_range = "1024-1026"
    }
  ]
  custom_rules = []
  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}

