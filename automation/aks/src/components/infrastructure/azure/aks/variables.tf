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

variable "storage_account_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "service_cidr" {
  type        = string
  description = "A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges."
  default     = "10.11.128.0/18"
}

variable "dns_service_ip" {
  type        = string
  description = "An IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr."
  default     = "10.11.128.10"
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
  default     = "1.15.11"
}

variable "docker_bridge_cidr" {
  type        = string
  description = "A CIDR notation IP range assigned to the Docker bridge network. It must not overlap with any Subnet IP ranges or the Kubernetes service address range."
  default     = "172.17.0.1/16"
}

variable "admin_username" {
  type        = string
  description = "The username that will be created on the worker nodes for administration"
  default     = "systemadmin"
}
