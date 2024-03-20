resource "azurerm_log_analytics_workspace" "insights" {
  name                = "logs-${random_pet.primary.id}"
  location            = var.location
  resource_group_name = var.resource_group_name
  retention_in_days   = var.retention_in_days
  sku                 = var.sku
   
}

resource "azurerm_log_analytics_solution" "Log_Analytics_Solution_ContainerInsights" {
  for_each = var.solution_plan_map
  solution_name         = each.key
  location              = azurerm_log_analytics_workspace.insights.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.insights.id
  workspace_name        = azurerm_log_analytics_workspace.insights.name

   plan {
    product   = each.value.product
    publisher = each.value.publisher
  }

}