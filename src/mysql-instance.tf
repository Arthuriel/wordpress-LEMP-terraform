resource "azurerm_virtual_network" "mysql" {
  name                = "POC-DANIEL-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name
}

resource "azurerm_subnet" "mysql" {
  name                 = "mysql-subnet"
  resource_group_name  = azurerm_resource_group.wordpress.name
  virtual_network_name = azurerm_virtual_network.mysql.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_interface" "mysql" {
  name                = "mysql-nic"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.mysql.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mysql.id
  }
}

resource "azurerm_network_security_group" "mysql" {
  name                = "mysql-nsg"
  location            = azurerm_resource_group.wordpress.location
  resource_group_name = azurerm_resource_group.wordpress.name

  security_rule {
    name                       = "mysql"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "10.0.2.0/24" #open to wp-instance private IP
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

# resource "azurerm_network_security_rule" "mysql" {
#   name                        = "mysql"
#   priority                    = 310
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "3306"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.wordpress.name
#   network_security_group_name = azurerm_network_security_group.mysql.name
# }

resource "azurerm_network_interface_security_group_association" "mysql" {
  network_interface_id      = azurerm_network_interface.mysql.id
  network_security_group_id = azurerm_network_security_group.mysql.id
}


resource "azurerm_public_ip" "mysql" {
  name                = "mysql-public-ip"
  resource_group_name = azurerm_resource_group.wordpress.name
  location            = azurerm_resource_group.wordpress.location
  allocation_method   = "Static"

  # tags = {
  #   environment = "Production"
  # }
}

resource "azurerm_linux_virtual_machine" "mysql" {
  name                = "mysql-machine"
  resource_group_name = azurerm_resource_group.wordpress.name
  location            = azurerm_resource_group.wordpress.location
  size                = "Standard_B2s"
  admin_username      = var.admin_username
  #admin_password      = var.admin_password
  #user_data          = file("/scripts/mysqlconfig.sh")
  disable_password_authentication = true
  custom_data                     = filebase64("./scripts/mysqlconfig.sh")
  network_interface_ids = [
    azurerm_network_interface.mysql.id,
  ]

  # admin_ssh_key {
  #   username   = var.admin_username
  #   public_key = "${path.module}/ssh_key.pem"
  # }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  #  admin_password {
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
    azurerm_virtual_network.mysql
  ]


  # provisioner "mysqlQueryFile" {
  #   source      = "development/workspace/wordpress-terraform/mysqlquery.txt"
  #   destination = "/etc/mysql/"
  # }
}