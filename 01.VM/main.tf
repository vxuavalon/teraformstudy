provider "azurerm" {
  version = "2.9.0"
  features{}
}
resource "azurerm_resource_group" "rg" {
    name = "rg-MyfirstTerraform"
    location = "east us"
    tags = {
        Environment = "Terraform Demo"
    }
}
resource "azurerm_virtual_network" "vnet" {
  name = "vnet-eastus2-001"
  address_space = ["10.0.0.0/16"]
  location = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet" {
  name ="snet-eastus-001"
  resource_group_name =azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix = "10.0.0.0/24"
}
resource "azurerm_public_ip" "publicip" {
  name = "pip-eastus-001"
  location = "eastus"
  resource_group_name=azurerm_resource_group.rg.name
  allocation_method   = "Static"
  tags = {
    Environment = "Prod"
  }
}
resource "azurerm_network_security_group" "nsg" {
  name = "nsg-sshallow-001"
  location = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  security_rule{
    name = "SSH"
    priority = 1001
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_network_interface" "nic" {
  name = "nic-01-dev-001"
  location="eastus"
  resource_group_name=azurerm_resource_group.rg.name

  ip_configuration{
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "vm" {
  name = "vmterraform"
  location = "eastus"
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size= "standard_B1s"
  storage_os_disk {
    name = "firstosdisk"
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
    computer_name  = "vmterraform"
    admin_username = "terrauser"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}