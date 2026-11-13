locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    managed_by  = "terraform"
  })
}

module "rg_data" {
  source = "./modules/resource-group"


  name     = "rg-data-${var.environment}"
  location = var.location
  tags     = local.common_tags
}

module "storage" {
  source = "./modules/storage-account"

  name                = "st${var.environment}${var.storage_suffix}"
  resource_group_name = module.rg_data.name
  location            = module.rg_data.location
  tags                = local.common_tags
} 


