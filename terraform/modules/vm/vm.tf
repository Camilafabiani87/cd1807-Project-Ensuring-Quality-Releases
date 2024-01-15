resource "azurerm_network_interface" "test_nic" {
  name                = "${var.application_type}-${var.resource_type}-nic"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${var.public_ip_address_id}"
  }
}

resource "azurerm_linux_virtual_machine" "test_vm" {
  name                = "${var.application_type}-VM"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group}"
  size                = "Standard_DS2_v2"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.test_nic.id]
  source_image_id       = "/subscriptions/80ae9245-22ea-4f16-a42f-d5cebd7aac99/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/myPackerImage"
  admin_ssh_key {
    username   = "adminuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDGdbOz0BRHHMEMU/1LCEhZRcyKCJZJY7E5QaTqTpWrVK+7UdDs9r00lzmzUSskh2ODT7klwIUIOc95liN5hOpSKt2XmIMJiKta++pqdomkuuloIwSX/suCCC1wNA6UUDyKkjMIF0TegXPpKzGU+p05kRjLaHz20ZPRFBNBoyUwpWcegWSFOT7Fme5AFGqjJMVL5HuugsDdxIG0aqqN/s668u6rYa811SaRniM8aJ4EPCrCp1ov8QlkD24xiDrpPs+snY4fWbH2WcPqtqVb9Kd3AqawkYWE51FgUrZtCptAwdCrxlhZtX9YuqpWl6b+WsS3K+qlM2gWD/ne+oulx8XJoFfYh7jZH1E6EEl6fQKY/a5dN9osa7YdYjcnmO+FpIAM7194rSnkfZYdcIUiXjCeSvuR4Mg9Ggwk7+hUnQF4bNU1yjBWoVvTFH32qpdx4qHFF4pZJi6OxpvXrmpdvPgRj9Sm+wzc98AIWCTjdLA0uA4zgP7TAOLdku/BPlM8GME= camilafabiani.f@gmail.com"
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
