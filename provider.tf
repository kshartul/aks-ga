# Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.4.0"
    }
     azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
  backend "azurerm" {
    #resource_group_name  = "aksstracc01" #var.state_resource_group_name
    #storage_account_name = "aksstracc01"#var.state_storage_account_name
    #container_name       = "tfstate"
    #key                  = "terraform.tfstate"
  }
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks-cluster.kube_admin_config.0.cluster_ca_certificate)
}

# configure the Microsoft Azure Provider
provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

