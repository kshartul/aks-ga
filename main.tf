# creating virtual network
module "vnet" {
  source                = "./modules/vnet"
  resource_group_name   = var.resource_group_name
  location              = var.region
  address_space         = var.vnetCIDR
  subnet_address_prefix = var.subnetCIDRs
  environment           = var.environment
}

# creating EKS
module "eks" {
  source              = "./modules/kubernetes"
  location            = var.region
  resource_group_name = module.vnet.resource_group_name
  environment         = var.environment
  node_count          = var.node_count
  max_count           = var.max_node_count
  min_count           = var.min_node_count
  vnet_subnet_id      = module.vnet.public_subnet_id
  node_vm_size        = var.node_vm_size
  ad_groups           = var.ad_groups
  aks_admin_group_object_ids    = var.aks_admin_group_object_ids

}