 provider "azurerm" {
  version = "2.9.0"
  features{}
}
resource "azurerm_resource_group" "rg" {
    name = var.resourceGroupName
    location = var.location
    tags = {
        Environment = "Terraform Demo"
    }
}
resource "azurerm_virtual_network" "vnet" {
  name = "vnet-eastus2-001"
  address_space = ["10.0.0.0/16"]
  location = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet" {
  name ="snet-eastus-001"
  resource_group_name =azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix = "10.0.0.0/24"
}
resource "azurerm_network_security_group" "nsg" {
  name = "nsg-sshallow-001"
  location = var.location
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
  location= var.location
  resource_group_name=azurerm_resource_group.rg.name
  ip_configuration{
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_virtual_machine" "vm" {
  name = "vmterraform"
  location = var.location
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
   publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
os_profile {
    computer_name  = "vmterraform"
    admin_username = "terrauser"
    admin_password = "Password1234!"
  }
os_profile_windows_config{
  timezone = "Eastern Standard Time"
}
}
resource "azurerm_managed_disk" "disk01"{
  name = "vm-disk1"
  location = azurerm_resource_group.rg.location
  resource_group_name=azurerm_resource_group.rg.name
  storage_account_type="Standard_LRS"
  create_option = "Empty"
  disk_size_gb = 10
}
resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
  managed_disk_id = azurerm_managed_disk.disk01.id
  virtual_machine_id = azurerm_virtual_machine.vm.id
  lun = "10"
  caching = "ReadWrite"
}
