# Docs:  https://developer.hashicorp.com/terraform/language/block/terraform#required_providers
# Constrains which Terraform CLI versions can use this configuration.
terraform {
  required_providers {

    # Docs:  https://developer.hashicorp.com/terraform/language/block/terraform#provider-specific-settings
    # Declares the providers this module depends on and pins their version
    azurerm = {
      # The global source address for the provider you intend to use.
      source = "hashicorp/azurerm"
      # Specify which subset of available provider versions the module is compatible with.
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Configures the Azure Resource Manager provider.  The features block is required.
provider "azurerm" {
  features {}
}

# Docs:  https://developer.hashicorp.com/terraform/language/values/locals
# Local values let you assign a name to an expression for reuse within the module.
locals {
  caf_naming = {
    # Azure CAF Naming Convention
    workload      = "learntf"
    env           = "lab"
    region        = "westus"
    region_abbr   = "wus"
  }

  caf_tags = {
    # Azure CAF Tags
    owner      = "infra"
    managed_by = "terraform"
    costcenter = "111-222-3333"
  }
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
# Manages an Azure Resource Group - a logical container for related Azure resources.
resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.caf_naming.workload}-${local.caf_naming.env}-${local.caf_naming.region_abbr}-001"
  location = local.caf_naming.region

  tags = local.caf_tags
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
# Manages an Azure Storage Account - a secure account for storing data objects in the cloud.
resource "azurerm_storage_account" "sa" {
  name                     = "sa${local.caf_naming.workload}${local.caf_naming.env}001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = local.caf_naming.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.caf_tags
}

# Docs:  https://developer.hashicorp.com/terraform/language/values/outputs
# Outputs are printed after 'terraform apply' and queryable via 'terraform output'.

# Resource Group outputs
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

# Storage Account outputs
output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}
