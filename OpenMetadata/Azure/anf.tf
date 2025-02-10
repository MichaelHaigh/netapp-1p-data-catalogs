resource "azurerm_netapp_account" "om_netapp_account" {
  name                = "openmetadata-${terraform.workspace}-netappaccount"
  location            = azurerm_resource_group.om_resource_group.location
  resource_group_name = azurerm_resource_group.om_resource_group.name

  tags = {
    environment = "${terraform.workspace}"
    creator     = "${var.creator_tag}"
  }
}

resource "azurerm_netapp_pool" "om_anf_pool" {
  name                = "openmetadata-${terraform.workspace}-netapppool"
  account_name        = azurerm_netapp_account.om_netapp_account.name
  location            = azurerm_resource_group.om_resource_group.location
  resource_group_name = azurerm_resource_group.om_resource_group.name
  service_level       = var.anf_service_level
  size_in_tb          = var.anf_pool_size

  tags = {
    environment = "${terraform.workspace}"
    creator     = "${var.creator_tag}"
  }
}
