# Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.96.0"
    }
  }
  backend "azurerm" {
    #resource_group_name  = "aksstracc01" #var.state_resource_group_name
    #storage_account_name = "aksstracc01"#var.state_storage_account_name
    #container_name       = "tfstate"
    #key                  = "terraform.tfstate"
  }
}

# configure the Microsoft Azure Provider
provider "azurerm" {
  #skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}

