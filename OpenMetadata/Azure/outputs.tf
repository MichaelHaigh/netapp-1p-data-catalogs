output "az_kubeconfig_cmd" {
  value = "az aks get-credentials --resource-group openmetadata-${terraform.workspace}-rg --name openmetadata-${terraform.workspace}-cluster"
}
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.om_aks_cluster.kube_config_raw
  sensitive = true
}
output "openmetadata_airflow_password" {
  value     = random_string.openmetadata_airflow_password.result
  sensitive = true
}
output "opensearch_openmetadata_password" {
  value     = random_string.opensearch_openmetadata_password.result
  sensitive = true
}
output "opensearch_private_address" {
  value = instaclustr_opensearch_cluster_v2.om_opensearch.private_endpoint
}
output "postgresql_airflow_password" {
  value     = random_string.postgresql_airflow_password.result
  sensitive = true
}
output "postgresql_icpostgresql_password" {
  value     = instaclustr_postgresql_cluster_v2.om_postgres.default_user_password
  sensitive = true
}
output "postgresql_openmetadata_password" {
  value     = random_string.postgresql_openmetadata_password.result
  sensitive = true
}
output "postgresql_private_address" {
  value = instaclustr_postgresql_cluster_v2.om_postgres.data_centre[0].nodes[0].private_address
}
