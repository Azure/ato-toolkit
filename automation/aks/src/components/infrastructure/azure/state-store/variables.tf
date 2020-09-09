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
