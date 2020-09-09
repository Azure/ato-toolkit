#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"


# New azure service principal required with "Contributor" roles
# for the Azure Service Operator to have sufficient right to create Azure Resources
function generate_aso_service_principal {

    _timestamp="$(date "+%Y:%m:%d-%H:%M")"
    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _cluster_name=$(get_from_ini_or_error "$config_file" "c12:generated.aks_name")
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _prefix=$(ini_val "$config_file" c12.prefix)
    _key="azure/${_cluster_name}_aks_azure_service_operator_service_principal.tfstate"

    pushd  "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/terraform/azure_service_operator_service_principal" || return 1    

    terraform init \
       -backend-config "storage_account_name=$_storage_account_name" \
       -backend-config "container_name=$_container_name" \
       -backend-config "resource_group_name=$_container_rg" \
       -backend-config "key=$_key" \
       -backend-config "subscription_id=$_subscription_id" \
       -reconfigure

    terraform workspace select default

    terraform plan \
         -lock=true \
         -out "${_timestamp}.tfplan" \
         -var "prefix=$_prefix" \
         -var "cluster_name=$_cluster_name" \
         -var "subscription_id=$_subscription_id"


    terraform apply "${_timestamp}.tfplan"

    _azure_service_operator_service_principal_id=$(terraform output id)
    _azure_service_operator_service_principal_application_id=$(terraform output application_id)
    _azure_service_operator_service_principal_password=$(terraform output password)

    ini_val "$config_file" c12:generated.azure_service_operator_service_principal_id "$_azure_service_operator_service_principal_id"
    ini_val "$config_file" c12:generated.azure_service_operator_service_principal_application_id "$_azure_service_operator_service_principal_application_id"
    ini_val "$config_file" c12:generated.azure_service_operator_service_principal_password "$_azure_service_operator_service_principal_password"

    popd || return 1
}

# Renders HelmRelease config for  azure-service-operator
function render_and_copy_azure_service_operator {

    # Set the cloud environment, possible values include: AzurePublicCloud, AzureUSGovernmentCloud, AzureChinaCloud, AzureGermanCloud
    AZURE_CLOUD_ENV="AzurePublicCloud"

    info "Adding azure-service-operator files to $cluster_folder"

    info "Processing rendering azure-service-operator-values.yaml"
    subscription=$(ini_val "$config_file" azure.subscription)
    tenantId=$(az account list -o json | jq -r --arg SUB_ID "${subscription}" '.[] | select( .id == $SUB_ID ) | .tenantId')
    service_principal_application_id=$(ini_val "$config_file" c12:generated.azure_service_operator_service_principal_application_id )
    service_principal_password=$(ini_val "$config_file" c12:generated.azure_service_operator_service_principal_password )
    acr=$(ini_val "$config_file" c12:generated.regional_acr_name )
    
    # Base64 encoding required varables.
    acr=$acr \
    azurePublicCloud="$(echo -ne "${AZURE_CLOUD_ENV}" | base64)" \
    subscription="$(echo -ne "${subscription}" | base64)" \
    service_principal_application_id="$(echo -ne "${service_principal_application_id}" | base64)" \
    service_principal_password="$(echo -ne "${service_principal_password}"  | base64)" \
    tenantId="$(echo -ne "${tenantId}" | base64)" \
    envsubst < "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/manifests/azure-service-operator-template.yaml" > "$cluster_folder/azure-service-operator.yaml"

    pushd "$cluster_folder" >/dev/null || return 1
    cd ..

    info "Commiting settings for azure-service-operator-values"
    git add .
    git commit -m "Onboarding: Add azure-service-operator-values" || true
    git push
    popd >/dev/null || return 1
}


function render_azure_service_operator {

    if [[ $# -ne 1 ]];
    then
        error "Expecting 1 arguments for this function"
        return 1
    fi
    cluster_folder="$1"

    info "Generate Service Principal for azure-service-operator"
    generate_aso_service_principal
    info "Service Principal Generated"


    render_and_copy_azure_service_operator


    DEF_ASO_CHART_REPOSITORY="https://raw.githubusercontent.com/Azure/azure-service-operator/master/charts"
    DEF_ASO_HELM_CHART="azure-service-operator"
    DEF_ASO_HELM_CHART_VERSION="0.1.0"
    acr_name=$(ini_val "$config_file" c12:generated.regional_acr_name )

    import_chart_acr "${DEF_ASO_CHART_REPOSITORY}" "${DEF_ASO_HELM_CHART}" "${DEF_ASO_HELM_CHART_VERSION}" "${acr_name}"
    
    info "Importing azure-service-operator image into cluster ACR"
    import_image "$acr_name" "mcr.microsoft.com/k8s/azure-service-operator:latest"
    info "Importing azure-service-operator image into cluster ACR"

}

