resource_group_name         = "rg-stg-aks"
region                      = "eastus2"
vnetCIDR                    = ["10.163.0.0/16"]
subnetCIDRs                 = ["10.163.0.0/21"]
environment                 = "staging"
max_node_count              = 4
min_node_count              = 2
node_count                  = 2
node_vm_size                = "Standard_D2_v2"
aks_admin_group_object_ids  =  ["00000000-0000-0000-0000-000000000000"]
ad_groups                   = ["product1", "product2"]
  