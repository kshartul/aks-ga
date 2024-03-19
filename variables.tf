# region
variable "region" {
  type        = string
  description = "Region"
}

# Virtual Network CIDR
variable "vnetCIDR" {
  type        = list(string)
  description = "Virtual Network CIDR"
}

# subnet CIDRs
variable "subnetCIDRs" {
  type        = list(string)
  description = "Subnet CIDRs"
}

# environment
variable "environment" {
  type        = string
  description = "Environment"
}

# max node count 
variable "max_node_count" {
  type        = number
  description = "Maximun node count for worker node"
}

# min node count 
variable "min_node_count" {
  type        = number
  description = "Minimum node count for worker node"
}

# size of worker node
variable "node_vm_size" {
  type        = string
  description = "Size of worker node"
}
# node count
variable "node_count" {
  type        = number
  description = "The required node count for worker node"
}
variable "admin_username" {
  description = "Admin username for cluster nodes."
  default     = "azureuser"
}
variable "resource_group_name" {
  description = "teraform state file resource group name."
}
#variable "storage_account_name" {
#  description = "teraform storage account name."
#}



