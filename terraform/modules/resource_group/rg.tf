resource "azurerm_resource_group" "Azuredevops" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}