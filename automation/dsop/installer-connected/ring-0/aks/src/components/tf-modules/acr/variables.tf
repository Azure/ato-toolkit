variable "resource_group_name" {
  description = "The name of the exsisitng resource group where all the resources will be created"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "The set of tags to be used to add to all resrouces created"
  default     = {}
}

variable "name" {
  type        = string
  description = "The name for this Registry"
}

variable "worker_subnet_id" {
  type        = string
  description = "The worker_subnet_id to limit ingress to this ACR to"
}

variable "principal_ids" {
  description = "A list of roles and principals (User, Group, Service Principals) to assign permissions"
  type        = list(object({ role = string, principal = string }))
}
