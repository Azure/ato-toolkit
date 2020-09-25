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

variable "ssh_pub_key" {
  type        = string
  description = "The path to the ssh public key to be added"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster where the key was generated and will have access to the cluster repo"
}

variable "repository" {
  type    = string
  default = "cluster-state"
}

variable "application" {
  type    = string
  default = "c12-system-flux"
}
