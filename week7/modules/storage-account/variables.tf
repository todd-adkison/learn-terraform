variable "name" {
  description = "Storage account name (3-24 lowercase letters/numbers, globally unique)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Name must be 3-24 characters, lowercase letters and numbers only."
  }
}

variable "resource_group_name" {
  description = "resource group to deploy into."
  type        = string
}

variable "location" {
  description = "Azure location."
  type        = string
}

variable "account_tier" {
  description = "Standard or premium."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "tags to apply"
  type        = map(string)
  default     = {}
}


