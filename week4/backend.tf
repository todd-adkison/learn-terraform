# Docs: https://developer.hashicorp.com/terraform/language/backend
terraform {
  # Docs: https://developer.hashicorp.com/terraform/language/backend/azurerm  
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate21558"
    container_name       = "todda-tfstate"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}
