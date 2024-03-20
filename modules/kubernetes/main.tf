# backend

#data "azurerm_client_config" "current" {}

resource "random_pet" "primary" {}

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

locals {
  login_server = azurerm_container_registry.acr.login_server
  username     = azurerm_container_registry.acr.admin_username
  password     = azurerm_container_registry.acr.admin_password
}

locals {
  dockercreds = {
    auths = {
      "${local.login_server}" = {
        auth = base64encode("${local.username}:${local.password}")
      }
    }
  }
}
resource "kubernetes_secret" "docker_credentials" {
  metadata {
    name = "docker-credentials"
  }

  data = {
    ".dockerconfigjson" = jsonencode(local.dockercreds)
  }

  type = "kubernetes.io/dockerconfigjson"
}
resource "azuread_group" "aks_administrators" {
  display_name        = "aks${var.environment}-admin"
  description = "Kubernetes administrators for the ${var.environment} cluster."
}

resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${random_pet.primary.id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = 30
  sku                 = "PerGB2018"
}
resource "azurerm_log_analytics_solution" "Log_Analytics_Solution_ContainerInsights" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.insights.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.insights.id
  workspace_name        = azurerm_log_analytics_workspace.insights.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
# creating AKS cluster
resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = "${var.environment}aks-cl01"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.resource_group_name
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${var.environment}-node-group"
  
  oms_agent {
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.insights.id
    }
  
  ingress_application_gateway {
    subnet_id = azurerm_subnet.app_gwsubnet.id
  }

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
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
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
  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = tls_private_key.ssh_key.public_key_openssh
    }
  }  
  
  identity {
    type = "SystemAssigned"
  }
  role_based_access_control_enabled = true
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
data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.aks-cluster.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8saks-cluster
  ]
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.aks-cluster.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.aks-cluster
  ]
}
resource "azurerm_monitor_workspace" "az-mon-ws" {
  name                = "amon-${random_pet.primary}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_monitor_data_collection_endpoint" "az-mon-dc" {
  name                = "msprom--${random_pet.primary}-${azurerm_kubernetes_cluster.aks-cluster.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
}

resource "azurerm_monitor_data_collection_rule" "az-dc-rule" {
  name                        = "msprom--${random_pet.primary}-${azurerm_kubernetes_cluster.aks-cluster.name}"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.az-mon-dc.id

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.az-mon-ws.id
      name               = azurerm_monitor_workspace.az-mon-ws.name
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = [azurerm_monitor_workspace.az-mon-ws.name]
  }
}

# associate to a Data Collection Rule
resource "azurerm_monitor_data_collection_rule_association" "az_dcr_to_aks" {
  name                    = "dcr-${azurerm_kubernetes_cluster.aks-cluster.name}"
  target_resource_id      = azurerm_kubernetes_cluster.aks-cluster.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.az-dc-rule.id
}

# associate to a Data Collection Endpoint
resource "azurerm_monitor_data_collection_rule_association" "az_dce_to_aks" {
  target_resource_id          = azurerm_kubernetes_cluster.aks-cluster.id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.az-mon-dc.id
}
