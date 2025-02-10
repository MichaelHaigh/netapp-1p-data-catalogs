# Azure Settings
variable "sp_creds" {
  type        = string
  description = "The file path containing the service principal credentials"
}
variable "azr_region" {
  type        = string
  description = "The Azure region"
}
variable "creator_tag" {
  type        = string
  description = "The value to apply to the 'creator' key tag"
}

# Instaclustr Settings
variable "ic_creds" {
  type        = string
  description = "The file path containing the Instaclustr username and API key JSON file"
}
variable "ic_region" {
  type        = string
  description = "The Instaclustr region (see https://registry.terraform.io/providers/instaclustr/instaclustr/latest/docs/resources/postgresql_cluster_v2#nested-schema-for-data_centre for options)"
}
variable "ic_provider_account" {
  type        = string
  description = "If using Instaclustr RIYOA (run in your own account), the name of the customer account. Specify an empty string or null to use Instaclustr's cloud."
}
variable "ic_resource_group" {
  type        = string
  description = "If using Instaclustr RIYOA (run in your own account), the name of the resource group to deploy into. Specify an empty string or null if using Instaclustr's cloud."
}

# VNet Settings
variable "om_vnet_cidr" {
  type        = string
  description = "The CIDR IP range for the VNet"
}
variable "om_vnet_dns_ip" {
  type        = string
  description = "The DNS IP for the VNet"
}
variable "om_anf_cidr" {
  type        = string
  description = "The CIDR IP range for the ANF subnet"
}
variable "om_aks_nodepool_cidr" {
  type        = string
  description = "The CIDR IP range for the nodepool VMs"
}
variable "om_aks_services_cidr" {
  type        = string
  description = "The CIDR IP range for the services"
}
variable "om_aks_services_dns_ip" {
  type        = string
  description = "The IP of the DNS Service, must be within the aks_services_cidr CIDR"
}
variable "om_aks_pods_cidr" {
  type        = string
  description = "The CIDR IP range for the pods"
}

# AKS Cluster Settings
variable "aks_kubernetes_version" {
  type        = string
  description = "The Kubernetes version of the AKS cluster"
}
variable "aks_trident_version" {
  type        = string
  description = "The trident version to use for the output commands"
}

# Node Pool Settings
variable "aks_node_count" {
  type        = number
  description = "The initial node count for the default_node_pool"
}
variable "aks_image_size" {
  type        = string
  description = "The VM / image size for the default_node_pool"
}
variable "aks_os_disk_size_gb" {
  type        = string
  description = "The VM / image OS disk size for the default_node_pool"
  default     = 30
}

# ANF Settings
variable "anf_service_level" {
  type        = string
  description = "The ANF Storage Class service level (must be one of Standard, Premium, Ultra)"

  validation {
    condition     = contains(["Standard", "Premium", "Ultra"], var.anf_service_level)
    error_message = "Valid values for anf_service_level: (Standard, Premium, Ultra)"
  }
}
variable "anf_pool_size" {
  type        = number
  description = "The size of the ANF capacity pool (in TiB)"
}

# PostgreSQL Settings
variable "postgresql_sla_tier" {
  type        = string
  description = "The Instaclustr SLA tier of the cluster (must be one of PRODUCTION, NON_PRODUCTION)"

  validation {
    condition     = contains(["PRODUCTION", "NON_PRODUCTION"], var.postgresql_sla_tier)
    error_message = "Valid values for postgresql_sla_tier: (PRODUCTION, NON_PRODUCTION)"
  }
}
variable "postgresql_version" {
  type        = string
  description = "The version of PostgreSQL to run on the cluster"
}
variable "postgresql_replication" {
  type        = string
  description = "The PostgreSQL replication mode (must be one of ASYNCHRONOUS, SYNCHRONOUS)"

  validation {
    condition     = contains(["ASYNCHRONOUS", "SYNCHRONOUS"], var.postgresql_replication)
    error_message = "Valid values for postgresql_replication: (ASYNCHRONOUS, SYNCHRONOUS)"
  }
}
variable "postgresql_node_count" {
  type        = number
  description = "The number of PostgreSQL nodes in the cluster (must be between 1 and 5, inclusive)"
}
variable "postgresql_node_size" {
  type        = string
  description = "The PostgreSQL node size (must be one of PGS-PRD-Standard_E16s_v4-ANF-2048, PGS-PRD-Standard_E32s_v4-ANF-2048, PGS-PRD-Standard_E8s_v4-ANF-2048)"

  validation {
    condition     = contains(["PGS-PRD-Standard_E16s_v4-ANF-2048", "PGS-PRD-Standard_E32s_v4-ANF-2048", "PGS-PRD-Standard_E8s_v4-ANF-2048"], var.postgresql_node_size)
    error_message = "Valid values for postgresql_node_size: (PGS-PRD-Standard_E16s_v4-ANF-2048, PGS-PRD-Standard_E32s_v4-ANF-2048, PGS-PRD-Standard_E8s_v4-ANF-2048)"
  }
}
variable "postgresql_network" {
  type        = string
  description = "The PostgreSQL private network CIDR for the data center, must be between /12 and /22, and should not overlap with om_vnet_cidr"
}
variable "postgresql_storage_net" {
  type        = string
  description = "The private network CIDR for Azure NetApp Files which backs the PostgreSQL cluster, must be between /16 and /28, and should not overlap with om_vnet_cidr or postgresql_network"
}

# OpenSearch Settings
variable "opensearch_sla_tier" {
  type        = string
  description = "The Instaclustr SLA tier of the cluster (must be one of PRODUCTION, NON_PRODUCTION)"

  validation {
    condition     = contains(["PRODUCTION", "NON_PRODUCTION"], var.opensearch_sla_tier)
    error_message = "Valid values for opensearch_sla_tier: (PRODUCTION, NON_PRODUCTION)"
  }
}
variable "opensearch_version" {
  type        = string
  description = "The version of OpenSearch to run on the cluster"
}
variable "opensearch_data_node_count" {
  type        = number
  description = "The number of OpenSearch data nodes in the cluster (must be a multiple of 3)"

  validation {
    condition     = var.opensearch_data_node_count % 3 == 0
    error_message = "opensearch_data_node_count must be a multiple of 3"
  }
}
variable "opensearch_network" {
  type        = string
  description = "The OpenSearch private network CIDR for the data center, must be between /12 and /22, and should not overlap with om_vnet_cidr nor postgresql_network"
}
variable "opensearch_data_node_size" {
  type        = string
  description = "The OpenSearch data node size (see https://registry.terraform.io/providers/instaclustr/instaclustr/latest/docs/resources/opensearch_cluster_v2 for all options)"
}
variable "opensearch_manager_node_size" {
  type        = string
  description = "The OpenSearch cluster manager node size (see https://registry.terraform.io/providers/instaclustr/instaclustr/latest/docs/resources/opensearch_cluster_v2 for all options)"
}
variable "opensearch_dashboard_node_size" {
  type        = string
  description = "The OpenSearch dashboard node size (see https://registry.terraform.io/providers/instaclustr/instaclustr/latest/docs/resources/opensearch_cluster_v2 for all options)"
}

# Authorized Networks
variable "authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access."
  default     = []
}
