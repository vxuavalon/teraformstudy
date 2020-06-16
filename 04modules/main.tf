provider "azurerm" {
  version = "2.9.0"
  features{}
}

module"resoure_group" {
  source = "./modules/ResourceGroup"
  resourceGroupName = "modules-rg"
}

module "network" {
  source = "./modules/network"
  vnet_name = "moduel-net"
  resource_group_name = module.resoure_group.rg_name
  address_space = "10.1.0.0/16"
  dns_servers = ["8.8.8.8","8.8.4.4"]
  subnet_prefixes  = ["10.1.1.0/24", "10.1.2.0/24","10.1.3.0/24","10.1.4.0/24"]
  subnet_names  = ["subnet1", "subnet2", "subnet3","subnet4"]

  tags = {
    environment = "dev"
    costcenter  = "it"
  }
}
resource "azurerm_network_interface" "nic" {
  count =2 
  name = "${element(var.vm, count.index)}"
  location ="eastus"
  resource_group_name = module.resoure_group.rg_name
  ip_configuration{
    name = "internal"
    subnet_id = module.network.vnet_subnets[0]
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
    count=2
    name = "${element(var.vm, count.index)}"
    location = "eastus"
    resource_group_name = module.resoure_group.rg_name
    network_interface_ids = ["${azurerm_network_interface.nic[count.index].id}"]
    vm_size= "standard_B1s"
    storage_os_disk {
    name = "firstosdisk-${count.index}"
    caching="ReadWrite"
    create_option="FromImage"
    managed_disk_type = "Standard_LRS"
  }
  storage_image_reference{
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
os_profile {
    computer_name  = "vmterraform-${count.index}"
    admin_username = "terrauser"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

