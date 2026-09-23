variable "prefix" {
  description = "Optional prefix list or string for the resource naming convention."
  type        = list(string)
  default     = []
}

variable "workload" {
  description = "The name of the workload, application, or service identifier."
  type        = string
  default     = "learntf"
}

variable "environment" {
  description = "The environment identifier (e.g., prod, dev, staging, test)."
  type        = string
  default     = "lab"
}

variable "location" {
  description = "The Azure region short code (e.g., eus for East US, wus for West US)."
  type        = string
  default     = "wus"
}

variable "region" {
  description = "The Azure region long code."
  type        = string
  default     = "westus"
}

variable "instance" {
  description = "A sequential instance number for resource uniqueness (e.g., '001')."
  type        = string
  default     = "001"
}
