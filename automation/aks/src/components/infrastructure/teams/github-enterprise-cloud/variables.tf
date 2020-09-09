variable "access_token" {
  type        = string
  description = "The PAT for Github"
}

variable "org" {
  type        = string
  description = "The name of the organization in github"
}

variable "prefix" {
  type        = string
  description = "Prefix to be added to all C12 created resources"
}

variable "applications" {
  type        = list
  description = "List of applications to link github teams to github repos for."
  default     = []
}

variable "subscription_id" {
  type        = string
  description = "The AzureAD Subscription ID where the deployment should be created"
}
