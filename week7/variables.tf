variable "subscription_id" {
  description = "Target Azure subscription ID."
  type        = string
  default     = "dd8709d6-494b-401f-b722-023c57caccd1"
}

variable "location" {
  description = "Default Azure region"
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "Environment name (dev,test, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "storage_suffix" {
  description = "Short unique suffix for the storage account name."
  type        = string
}
