
variable "prefix" {
  type        = string
  description = "Prefix to be added to all C12 created resources"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster where the key was generated and will have access to the cluster repo"
}

variable "subscription_id" {
  type        = string
  description = "The AzureAD Subscription ID where the deployment should be created"
}