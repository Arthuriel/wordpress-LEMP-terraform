resource "azurerm_virtual_network" "wordpress" {
  name                = "POC-DANIEL-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name
}

resource "azurerm_subnet" "wordpress" {
  name                 = "wordpress-subnet"
  resource_group_name  = azurerm_resource_group.wordpress.name
  virtual_network_name = azurerm_virtual_network.wordpress.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "wordpress" {
  name                = "wordpress-nic"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.wordpress.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.wordpress.id
  }
}

resource "azurerm_network_security_group" "wordpress" {
  name                = "wordpress-nsg"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  security_rule {
    name                       = "http"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*" #open to internet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "189.100.69.161" #my local machine public ip
    destination_address_prefix = "*"
  }
}

# resource "azurerm_network_security_rule" "wordpress" {
#   name                        = "http"
#   priority                    = 320
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.wordpress.name
#   network_security_group_name = azurerm_network_security_group.wordpress.name
# }

resource "azurerm_network_interface_security_group_association" "wordpress" {
  network_interface_id      = azurerm_network_interface.wordpress.id
  network_security_group_id = azurerm_network_security_group.wordpress.id
}

resource "azurerm_public_ip" "wordpress" {
  name                = "wordpress-public-ip"
  resource_group_name = azurerm_resource_group.wordpress.name
  location            = azurerm_resource_group.wordpress.location
  allocation_method   = "Static"

  # tags = {
  #   environment = "Production"
  # }
}

resource "azurerm_linux_virtual_machine" "wordpress" {
  name                = "wordpress-machine"
  resource_group_name = azurerm_resource_group.wordpress.name
  location            = azurerm_resource_group.wordpress.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  #admin_password      = var.admin_password
  # user_data           = file("/scripts/wpconfig.sh")
  disable_password_authentication = true
  custom_data                     = filebase64("./scripts/wpconfig.sh")
  network_interface_ids = [
    azurerm_network_interface.wordpress.id,
  ]

  # admin_ssh_key {
  #   username   = var.admin_username
  #   public_key = "${path.module}/ssh_key.pem"
  # }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  # admin_password {
  #   password = ""
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_virtual_network.wordpress
  ]

  # provisioner "File" {
  #   source      = "development/workspace/wordpress-terraform/etc/nginx/sites-available/wordpress"
  #   destination = "/etc/nginx/sites-available"
  # }
}