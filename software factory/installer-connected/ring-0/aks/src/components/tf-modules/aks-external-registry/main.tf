# This grants the SP that is configured in aks to pull images from the repository we've just created in
# the acr resource. https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster
# This assignment has the same effect as  "az role assignment create --assignee <appId> --scope <acrId> --role acrpull"
# This is enough for AKS to pull images from the acr registry, no need to configure any oher setting
# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks
resource "azurerm_role_assignment" "acr_spn_pull_role_assn" {
  role_definition_name = "AcrPull"
  scope                = var.acr_id
  principal_id         = var.aks_service_principal_id
}
