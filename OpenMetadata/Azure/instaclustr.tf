resource "instaclustr_postgresql_cluster_v2" "om_postgres" {
  name                    = "openmetadata-${terraform.workspace}-postgresql"
  sla_tier                = var.postgresql_sla_tier
  postgresql_version      = var.postgresql_version
  extensions              = [ "PG_CRON" ]
  private_network_cluster = false
  synchronous_mode_strict = false

  data_centre {
    cloud_provider        = "AZURE_AZ"
    name                  = "AZURE_AZ_${var.ic_region}"
    region                = var.ic_region
    provider_account_name = var.ic_provider_account == "" ? null : var.ic_provider_account
    network               = var.postgresql_network
    node_size             = var.postgresql_node_size
    number_of_nodes       = 2

    client_to_cluster_encryption = false
    intra_data_centre_replication {
      replication_mode = var.postgresql_replication
    }

    azure_settings {
      storage_network = var.postgresql_storage_net
      resource_group  = var.ic_resource_group == "" ? null : var.ic_resource_group
    }

    tag {
        key   = "environment"
        value = "${terraform.workspace}"
    }
  }
}

resource "instaclustr_opensearch_cluster_v2" "om_opensearch" {
  name                    = "openmetadata-${terraform.workspace}-opensearch"
  sla_tier                = var.opensearch_sla_tier
  opensearch_version      = var.opensearch_version
  load_balancer           = true
  pci_compliance_mode     = false
  private_network_cluster = false

  data_centre {
    cloud_provider        = "AZURE_AZ"
    name                  = "AZURE_AZ_${var.ic_region}"
    region                = var.ic_region
    provider_account_name = var.ic_provider_account == "" ? null : var.ic_provider_account
    network               = var.opensearch_network
    number_of_racks       = 3
    private_link          = false

    azure_settings {
      resource_group  = var.ic_resource_group == "" ? null : var.ic_resource_group
    }

    tag {
        key   = "environment"
        value = "${terraform.workspace}"
    }
  }

  data_nodes {
    node_count = var.opensearch_data_node_count
    node_size  = var.opensearch_data_node_size
  }
  cluster_manager_nodes {
    dedicated_manager = true
    node_size         = var.opensearch_manager_node_size
  }
  opensearch_dashboards {
    node_size = var.opensearch_dashboard_node_size
  }

  index_management_plugin    = true
  alerting_plugin            = false
  anomaly_detection_plugin   = false
  asynchronous_search_plugin = false
  icu_plugin                 = false
  knn_plugin                 = false
  notifications_plugin       = false
  reporting_plugin           = false
  sql_plugin                 = false
}

resource "instaclustr_cluster_network_firewall_rules_v2" "om_postgres_firewall" {
  cluster_id = instaclustr_postgresql_cluster_v2.om_postgres.id

  dynamic "firewall_rule" {
    for_each = var.authorized_networks
    iterator = network
    content {
      network = network.value["cidr_block"]
      type    = "POSTGRESQL"
    }
  }
}

resource "instaclustr_cluster_network_firewall_rules_v2" "om_opensearch_firewall" {
  cluster_id = instaclustr_opensearch_cluster_v2.om_opensearch.id

  dynamic "firewall_rule" {
    for_each = var.authorized_networks
    iterator = network
    content {
      network = network.value["cidr_block"]
      type    = "OPENSEARCH"
    }
  }

  dynamic "firewall_rule" {
    for_each = var.authorized_networks
    iterator = network
    content {
      network = network.value["cidr_block"]
      type    = "OPENSEARCH_DASHBOARDS"
    }
  }
}

resource "instaclustr_azure_vnet_peer_v2" "om_postgres_peer" {
  peer_virtual_network_name = azurerm_virtual_network.om_vnet.name
  peer_subnets              = [var.om_vnet_cidr]
  peer_resource_group       = azurerm_resource_group.om_resource_group.name
  peer_subscription_id      = jsondecode(file(var.sp_creds)).subscriptionId
  cdc_id                    = instaclustr_postgresql_cluster_v2.om_postgres.data_centre[0].id
}

resource "instaclustr_azure_vnet_peer_v2" "om_opensearch_peer" {
  peer_virtual_network_name = azurerm_virtual_network.om_vnet.name
  peer_subnets              = [var.om_vnet_cidr]
  peer_resource_group       = azurerm_resource_group.om_resource_group.name
  peer_subscription_id      = jsondecode(file(var.sp_creds)).subscriptionId
  cdc_id                    = instaclustr_opensearch_cluster_v2.om_opensearch.data_centre[0].id
}

resource "random_string" "openmetadata_airflow_password" {
  length           = 12
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  special          = true
  override_special = "!"
}

resource "random_string" "postgresql_airflow_password" {
  length           = 12
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  special          = true
  override_special = "!"
}

resource "random_string" "postgresql_openmetadata_password" {
  length           = 12
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  special          = true
  override_special = "!"
}

resource "random_string" "opensearch_openmetadata_password" {
  length           = 12
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  numeric          = true
  special          = true
  override_special = "!"
}

resource "terraform_data" "setup_postgresql" {
  triggers_replace = [
    instaclustr_postgresql_cluster_v2.om_postgres.id
  ]
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/postgresql_setup.sh"
    environment = {
      firewall_depends_on = instaclustr_cluster_network_firewall_rules_v2.om_postgres_firewall.id
      host                = instaclustr_postgresql_cluster_v2.om_postgres.data_centre[0].nodes[0].public_address
      ps_af_password      = random_string.postgresql_airflow_password.result
      ps_ic_password      = instaclustr_postgresql_cluster_v2.om_postgres.default_user_password
      ps_om_password      = random_string.postgresql_openmetadata_password.result
    }
  }
}

resource "terraform_data" "setup_opensearch" {
  triggers_replace = [
    instaclustr_opensearch_cluster_v2.om_opensearch.id
  ]
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/opensearch_setup.sh"
    environment = {
      firewall_depends_on = instaclustr_cluster_network_firewall_rules_v2.om_opensearch_firewall.id
      host                = instaclustr_opensearch_cluster_v2.om_opensearch.load_balancer_connection_url
      os_ic_password      = instaclustr_opensearch_cluster_v2.om_opensearch.default_user_password
      os_om_password      = random_string.opensearch_openmetadata_password.result
    }
  }
}
