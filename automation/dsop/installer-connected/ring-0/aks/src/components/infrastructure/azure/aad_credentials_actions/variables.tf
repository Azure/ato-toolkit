variable "access_token_username" {
  type        = string
  description = "The Username for where the PAT was generated"
}

variable "access_token" {
  type        = string
  description = "The PAT for Github"
}

variable "org" {
  type        = string
  description = "The name of the organization in github"
}

variable "repositories" {
  type        = list
  description = "The name of the repository where the secret sits"
}

variable "subscription_id" {
  type        = string
  description = "The AzureAD Subscription ID where the deployment should be created"
}

variable "prefix" {
  type        = string
  description = "Prefix to be added to all C12 created resources"
}

variable "ci_acr_name" {
  type        = string
  description = "the name of the acr registry that will be provisioned as secret in the pipeline as CI registry"
}