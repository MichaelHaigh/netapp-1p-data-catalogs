resource "azurerm_kubernetes_cluster" "om_aks_cluster" {
  name                                = "openmetadata-${terraform.workspace}-cluster"
  location                            = azurerm_resource_group.om_resource_group.location
  resource_group_name                 = azurerm_resource_group.om_resource_group.name
  dns_prefix                          = "aks${terraform.workspace}"
  kubernetes_version                  = var.aks_kubernetes_version
  private_cluster_enabled             = false
  private_cluster_public_fqdn_enabled = false

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_networks[*].cidr_block
  }

  default_node_pool {
    name            = "default"
    vnet_subnet_id  = azurerm_subnet.aks_node_subnet.id
    node_count      = var.aks_node_count
    vm_size         = var.aks_image_size
    os_disk_size_gb = var.aks_os_disk_size_gb

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  service_principal {
    client_id     = jsondecode(file(var.sp_creds)).appId
    client_secret = jsondecode(file(var.sp_creds)).password
  }

  tags = {
    environment = "${terraform.workspace}"
    creator     = "${var.creator_tag}"
  }

  network_profile {
    network_plugin     = "kubenet"
    service_cidr       = var.om_aks_services_cidr
    pod_cidr           = var.om_aks_pods_cidr
    dns_service_ip     = var.om_aks_services_dns_ip
  }
}

resource "terraform_data" "trident-install" {
  triggers_replace = [
    azurerm_kubernetes_cluster.om_aks_cluster.id
  ]
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/storage_class_setup.sh"
    environment = {
      aks_cluster_name      = azurerm_kubernetes_cluster.om_aks_cluster.name
      aks_network_name      = azurerm_virtual_network.om_vnet.name
      aks_subnet_name       = azurerm_subnet.om_anf_subnet.name
      aks_rg_name           = azurerm_resource_group.om_resource_group.name
      aks_trident_version   = var.aks_trident_version
      anf_capacity_pool     = azurerm_netapp_pool.om_anf_pool.name
      anf_service_level     = var.anf_service_level
      anf_service_level_lc  = lower(var.anf_service_level)
      azr_region            = var.azr_region
      sp_creds_app_id       = jsondecode(file(var.sp_creds)).appId
      sp_creds_password     = jsondecode(file(var.sp_creds)).password
      sp_creds_subscription = jsondecode(file(var.sp_creds)).subscriptionId
      sp_creds_tenant       = jsondecode(file(var.sp_creds)).tenant
    }
  }
}
