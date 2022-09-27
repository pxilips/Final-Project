# Create resource group
resource "azurerm_resource_group" "Server-RG" {
  name     = "Server-RG"
  location = "West Europe"
}

# Create virtual network
resource "azurerm_virtual_network" "Server-VPC" {
  name                = "Server-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Server-RG.location
  resource_group_name = azurerm_resource_group.Server-RG.name
}

# Create subnet
resource "azurerm_subnet" "Server-SUBNET" {
  name                 = "Server-SUBNET"
  resource_group_name  = azurerm_resource_group.Server-RG.name
  virtual_network_name = azurerm_virtual_network.Server-VPC.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_public_ip" {
  name                = "Public_IP"
  location            = azurerm_resource_group.Server-RG.location
  resource_group_name = azurerm_resource_group.Server-RG.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "Server-NIC" {
  name                = "Server-NIC"
  location            = azurerm_resource_group.Server-RG.location
  resource_group_name = azurerm_resource_group.Server-RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.Server-SUBNET.id
    private_ip_address_allocation = "Dynamic"
 public_ip_address_id          = azurerm_public_ip.my_public_ip.id
  }
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "win-server" {
  name                = "Win-Server"
  resource_group_name = azurerm_resource_group.Server-RG.name
  location            = azurerm_resource_group.Server-RG.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.Server-NIC.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "Server-NSG" {
  name                = "Allow_RDP"
  location            = azurerm_resource_group.Server-RG.location
  resource_group_name = azurerm_resource_group.Server-RG.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "Server-NSGA" {
  network_interface_id      = azurerm_network_interface.Server-NIC.id
  network_security_group_id = azurerm_network_security_group.Server-NSG.id
}
