# backend

data "azurerm_client_config" "current" {}

# RSA key of size 4096 bits
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# storing the private-key locally
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "private_key.pem"
}

# storing the public-key locally
resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "public_key.pub"
}

# datasource to get Latest Azure AKS latest Version
data "azurerm_kubernetes_service_versions" "current" {
  location        = var.location
  include_preview = false
}
# creating azure container registry 
resource "azurerm_container_registry" "acr" {
  name                = "aks${var.environment}reg"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}
resource "azuread_group" "groups" {
  for_each         = toset(var.ad_groups)
  display_name     = each.value
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true
}

resource "azurerm_role_assignment" "example" {
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_group.aksadmngroup.object_id
}
# creating AKS cluster
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "${var.environment}aks-cl01"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.resource_group_name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.environment}-node-group"

  default_node_pool {
    name                = "${var.environment}pool"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    zones               = [1, 2, 3]
    enable_auto_scaling = true
    max_count           = var.max_count
    min_count           = var.min_count
    vnet_subnet_id      = var.vnet_subnet_id
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    tags = {
      "nodepool-type" = "system"
      "environment"   = var.environment
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
  }
  identity {
    type = "SystemAssigned"
  }
  
  
  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = tls_private_key.ssh_key.public_key_openssh
    }
  }  
  #RBAC and Azure AD Integration Block
   azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.aks_admin_group_object_ids
    azure_rbac_enabled     = true
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
  auto_scaler_profile {
    balance_similar_node_groups = true
  }
    
}
# role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "role_acr_pull" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     =  azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  skip_service_principal_aad_check = true
    depends_on = [
    azurerm_kubernetes_cluster.aks-cluster
  ]
}

resource "azurerm_role_assignment" "admin" {
  for_each = toset(var.aks_admin_group_object_ids)
  scope = azurerm_kubernetes_cluster.aks1.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = each.value
}

resource "azurerm_role_assignment" "namespace-groups" {
  for_each = toset(var.ad_groups)
  scope = azurerm_kubernetes_cluster.aks1.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = azuread_group.groups[each.value].id
}
