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
    resource_group_name  = "aks-infra-rg"
    storage_account_name = "aksinfra"
    container_name       = "aks"
    key                  = "terraform.tfstate"
    #use_oidc             = true
  }
}

# configure the Microsoft Azure Provider
provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  #use_oidc = true
}

# backend

data "azurerm_client_config" "current" {}