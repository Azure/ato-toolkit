# Input Variables
variable "location" {
  type        = string
  description = "The environment location"
}

variable "subscription_id" {
  type        = string
  description = "The AzureAD Subscription ID where the deployment should be created"
}

variable "prefix" {
  type        = string
  description = "Prefix to be added to all C12 created resources"
}

variable "address_space" {
  description = "The VNet address space in CIDR format"
  type        = string
  default     = "10.1.0.0/16"
}

variable "worker_address_prefix" {
  description = "The address prefix that will be used for the AKS workers in CIDR format"
  type        = string
  default     = "10.1.0.0/18"
}

variable "jumphost_address_prefix" {
  description = "The address prefix that will be used for the AKS workers in CIDR format"
  type        = string
  default     = "10.1.64.0/24"
}

