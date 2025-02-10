# Azure Settings
sp_creds    = "~/.azure/azure-sp-tme-demo2-terraform.json"
azr_region  = "eastus"
creator_tag = "mhaigh"

# Instaclustr Settings
ic_creds            = "~/.instaclustr/instaclustr-creds.json"
ic_region           = "EAST_US"
ic_provider_account = "riyoa-name" # Only needed for RIYOA, set to "" for Instaclustr's cloud
ic_resource_group   = "instaclustreastus"

# VNet Settings
om_vnet_cidr           = "10.20.0.0/22"
om_vnet_dns_ip         = "10.20.3.254"   # must be w/in om_vnet_cidr
om_anf_cidr            = "10.20.2.0/24"  # must be w/in om_vnet_cidr
om_aks_nodepool_cidr   = "10.20.0.0/23"  # must be w/in om_vnet_cidr
om_aks_services_cidr   = "172.16.0.0/16" # must not be w/in om_vnet_cidr
om_aks_services_dns_ip = "172.16.0.10"   # must be w/in om_aks_services_cidr
om_aks_pods_cidr       = "172.18.0.0/16" # must not be w/in om_vnet_cidr

# AKS Cluster Settings
aks_kubernetes_version  = "1.30.7"
aks_trident_version     = "24.10.0"

# Node Pool Settings
aks_node_count = 2
aks_image_size = "Standard_D4s_v3"

# ANF Settings
anf_service_level = "Standard"
anf_pool_size     = 2

# PostgreSQL Settings
postgresql_sla_tier    = "NON_PRODUCTION"
postgresql_version     = "16.6.0"
postgresql_replication = "ASYNCHRONOUS"
postgresql_node_size   = "PGS-PRD-Standard_E16s_v4-ANF-2048"
postgresql_node_count  = 2
postgresql_network     = "10.20.16.0/20" # must not be w/in om_vnet_cidr
postgresql_storage_net = "10.20.15.0/24" # must not be w/in om_vnet_cidr nor postgresql_network

# Opensearch Settings
opensearch_sla_tier            = "NON_PRODUCTION"
opensearch_version             = "2.18.0"
opensearch_network             = "10.20.32.0/20" # must not be w/in om_vnet_cidr nor postgresql_network
opensearch_data_node_count     = 3
opensearch_data_node_size      = "SRH-PRD-D2s_v5-120-an"
opensearch_manager_node_size   = "SRH-DM-PRD-D2as_v4-16-an"
opensearch_dashboard_node_size = "SRH-PRD-D2s_v5-120-an"

# Authorized Networks
authorized_networks = [
  {
    cidr_block   = "198.51.100.0/24"
    display_name = "company_range"
  },
  {
    cidr_block   = "203.0.113.30/32"
    display_name = "home_address"
  },
]
