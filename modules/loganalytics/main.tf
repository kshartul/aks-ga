resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${random_pet.primary.id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.retention_in_days
  sku                 = var.sku
   
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