# AKS cluster name 
output "kubernetes_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks-cluster.name
  description = "Name of the AKS Cluster"
}

# AKS Cluster ID
output "kubernetes_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks-cluster.id
  description = "ID of the AKS Cluster"
}

# FQDN of nodes
output "kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.aks-cluster.fqdn
}

# ACR ID
output "acr_id" {
  value = azurerm_container_registry.acr.id
}

# kubeconfig file
resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_certificate
  sensitive = true
}

output "client_key" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].cluster_ca_certificate
  sensitive = true
}

output "cluster_password" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].password
  sensitive = true
}

output "cluster_username" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].username
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config[0].host
  sensitive = true
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
  sensitive = true
}
output "registry_hostname" {
  value = azurerm_container_registry.acr.login_server
}

output "registry_un" {
  value = azurerm_container_registry.acr.admin_username
}

output "registry_pw" {
  value     = azurerm_container_registry.acr.admin_password
  sensitive = true
}

