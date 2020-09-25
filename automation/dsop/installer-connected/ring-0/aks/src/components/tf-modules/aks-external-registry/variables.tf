variable "acr_id" {
  type        = string
  description = "The ID for this Registry"
}

variable "aks_service_principal_id" {
  description = "The ID of the Service Principal that will be assigned with `ACRPull` permissions"
  type        = string
}
