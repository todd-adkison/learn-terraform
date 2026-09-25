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
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate21558"
    container_name       = "todda-tfstate"
    key                  = "terraform.tfstate"
  }
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
# Configures the Azure Resource Manager provider.  The features block is required.
provider "azurerm" {
  features {}
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
# Manages an Azure Resource Group - a logical container for related Azure resources.
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload}-${var.environment}-${var.location}-001"
  location = var.region

  tags = var.resource_tags
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
# Manages an Azure Storage Account - a secure account for storing data objects in the cloud.
resource "azurerm_storage_account" "sa" {
  name                     = "sa${var.workload}${var.environment}001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.resource_tags

  depends_on = [azurerm_resource_group.rg]
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
# Manages a Log Analytics (formally Operational Insights) Workspace.
resource "azurerm_log_analytics_workspace" "la" {
  name                = "la${var.workload}${var.environment}001"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.resource_tags

  depends_on = [azurerm_storage_account.sa]
}

# Docs: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
# Manages a Diagnostic Setting for an existing Resource.  
resource "azurerm_monitor_diagnostic_setting" "diag" {
  for_each                   = toset(["blob", "queue", "table", "file"])
  name                       = "enable-all-logs-${each.key}"
  target_resource_id         = "${azurerm_storage_account.sa.id}/${each.key}Services/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id

  # Enables all current and future log categories
  dynamic "enabled_log" {
    for_each = ["StorageRead", "StorageWrite", "StorageDelete"]
    content {
      category = enabled_log.value
    }
  }

  # Enforce transaction metrics
  enabled_metric {
    category = "Transaction"
  }
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

# Log Analytics Workspace outputs
output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.la.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.la.id
}
