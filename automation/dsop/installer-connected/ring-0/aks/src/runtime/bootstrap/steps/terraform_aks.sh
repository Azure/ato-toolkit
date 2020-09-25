#!/usr/bin/env bash
# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/tools.sh"

# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function terraform_aks(){

    local _timestamp
    local _location
    local _subscription
    local _prefix
    local _storage_account_name
    local _container_name
    local _container_rg
    local _service_principal_id
    local _service_principal_application_id
    local _service_principal_password
    local _regional_acr_name
    local _ci_acr_name
    local _aks_name
    local _ssh_key_location


    _timestamp=$(date "+%Y:%m:%d-%H:%M")

    info "Creating AKS Cluster"

    pushd ../../components/infrastructure/azure/aks/ || exit 2

    pwd

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)

    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)

    terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "location=$_location" \
        -var "subscription_id=$_subscription" \
        -var "prefix=$_prefix"\
        -var "storage_account_name=$_storage_account_name"\
        -var "container_name=$_container_name"\
        -var "resource_group_name=$_container_rg"

    terraform apply "${_timestamp}.tfplan"

    _service_principal_id=$(terraform output service_principal_id)
    _service_principal_application_id=$(terraform output service_principal_application_id)
    _service_principal_password=$(terraform output service_principal_password)
    _regional_acr_name=$(terraform output regional_acr_name)
    _ci_acr_name=$(terraform output ci_acr_name)
    _ssh_key_location="$(pwd)/$(terraform output ssh_key_location)"
    _aks_name="$(terraform output aks_name)"
    _disk_encryption_set_id="$(terraform output disk_encryption_set_id)"


    ini_val "$config_file" c12:generated.service_principal_id "$_service_principal_id"
    ini_val "$config_file" c12:generated.service_principal_application_id "$_service_principal_application_id"
    ini_val "$config_file" c12:generated.service_principal_password "$_service_principal_password"
    ini_val "$config_file" c12:generated.regional_acr_name "$_regional_acr_name"
    ini_val "$config_file" c12:generated.ci_acr_name "$_ci_acr_name"
    ini_val "$config_file" c12:generated.aks_name "$_aks_name"
    ini_val "$config_file" c12:generated.aks_ssh_key_location "$_ssh_key_location"
    ini_val "$config_file" c12:generated.disk_encryption_set_id "$_disk_encryption_set_id"


    rm "$_timestamp.tfplan"

    popd || exit 2

    info "Created AKS Cluster"

}

# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function destroy_aks(){

    local _timestamp
    local _location
    local _subscription
    local _prefix

    _timestamp=$(date "+%Y:%m:%d-%H:%M")

    info "Destroying AKS Cluster"

    pushd ../../components/infrastructure/azure/aks/ || exit 2

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)

    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)

    terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

    terraform plan \
        -lock=true \
        -destroy \
        -out "${_timestamp}.tfplan" \
        -var "location=$_location" \
        -var "subscription_id=$_subscription" \
        -var "prefix=$_prefix"\
        -var "storage_account_name=$_storage_account_name"\
        -var "container_name=$_container_name"\
        -var "resource_group_name=$_container_rg"

    terraform apply "${_timestamp}.tfplan"

    rm "$_timestamp.tfplan"
    rm -rf .terraform

    popd || exit 2

    info "Destroyed AKS Cluster"

}