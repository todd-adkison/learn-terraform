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
      version = "5.7.0"
    }
  }
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Configures the Azure Resource Manager provider.  The features block is required.
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
# Manages an Azure Resource Group - a logical container for related Azure resources.
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload}-${var.environment}-${var.location}-001"
  location = var.region

  tags = var.resource_tags
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
# Manages a user assigned identity
resource "azurerm_user_assigned_identity" "mi" {
  name                = "mi-${var.workload}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_client_config" "current" {}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
# Manages a key vault
resource "azurerm_key_vault" "kv" {
  name                       = "kv${var.workload}-${var.environment}-${var.location}-001"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  rbac_authorization_enabled = true
  sku_name                   = "standard"
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
}

resource "azurerm_role_assignment" "kv_role" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.mi.principal_id
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

# Key Vault outputs
output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

