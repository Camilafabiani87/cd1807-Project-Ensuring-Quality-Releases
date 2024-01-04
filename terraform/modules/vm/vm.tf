resource "azurerm_network_interface" "" {
  name                = ""
  location            = ""
  resource_group_name = ""

  ip_configuration {
    name                          = "internal"
    subnet_id                     = ""
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = ""
  }
}

resource "azurerm_linux_virtual_machine" "" {
  name                = ""
  location            = ""
  resource_group_name = ""
  size                = "Standard_DS2_v2"
  admin_username      = ""
  network_interface_ids = []
  admin_ssh_key {
    username   = "adminusercd"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRGUSROqoyOs/mKyINSvSYpXblFDgiM+2fXyQjLKFg+xq5mlIg/e08mYwh8w0Sn4jy4diAQa/zRwQKLoIkENFwdePMwSb41BNcqVlrbCoSFLEaa7S0PgrhN6etn/AcVvy9rDJtZvgmmca3FEKNGvRsUOqkp5kRZeQlhWabL8idXxOYS2eqcO/TgEIhXiXReivqz+g6R/FIOEnpzywjShsrehYvikYFUTZzc/xwpHzznJ2g/m6nE+0UWyvg1r+ReWOuemK8rhyFgVmqU41yEZ58TGeReoqic252BYWvG49iBciMJS8YMU7u3htDOYcN5GA0khHhuGEM7vKRNGLusb7hCtQNL6fvTJXpkAeKOY/Gej3rWBBZFj3Xv6zY8t0FzUkbAYE2+UICv6M5ik/T6167TCfmt46wWnYj6jx5Fjgh5f5SWQGuusw/ziGlo3sis8wHtqMUmUoLavlIJA3PzuSZzTkftYnXjpFPLiZDqiVx0ufv+9Ci6r2KGyUC2ltLfws= odl_user@SandboxHost-638399700139214454"
  }
  os_disk {
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
