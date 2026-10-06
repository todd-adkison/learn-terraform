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
  features {}
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
# Manages an Azure Resource Group - a logical container for related Azure resources.
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.workload}-${var.environment}-${var.location}-001"
  location = var.region

  tags = var.resource_tags
}

# Docs:  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
# Manages a virtual network including any configured subnets. Each subnet can optionally be configured with a security group to be associated with the subnet.
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.workload}-${var.environment}-${var.location}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name

  tags = var.resource_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.workload}-${var.environment}-${var.location}-001"
  location            = var.region
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "snet-${var.workload}-001"
    address_prefixes = ["10.0.1.0/24"]
    security_group   = azurerm_network_security_group.nsg.id
  }

  subnet {
    name             = "snet-${var.workload}-002"
    address_prefixes = ["10.0.2.0/24"]
  }

  tags = var.resource_tags
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

# Vnet outputs
output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}
output "virtual_network_id" {
  value = azurerm_virtual_network.vnet.id
}
