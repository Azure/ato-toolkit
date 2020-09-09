variable "subscription_id" {
  type        = string
  description = "The AzureAD Subscription ID where the deployment should be created"
}

variable "prefix" {
  type        = string
  description = "Prefix to be added to all C12 created resources"
}

variable "applications" {
  type        = list
  description = "List of applications to create groups for"
  default     = []
}
