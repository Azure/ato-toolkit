#!/usr/bin/env bash
# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function terraform_storage_account() {

    local _timestamp
    local _location
    local _subscription
    local _prefix
    local _storage_account_name
    local _container_name
    local _container_rg

    _timestamp=$(date "+%Y:%m:%d-%H:%M")


    info "Creating Storage Account for Terraform State"

    pushd ../../components/infrastructure/azure/state-store/ || exit 2

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)

    terraform init

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "location=$_location" \
        -var "subscription_id=$_subscription" \
        -var "prefix=$_prefix"

    terraform apply "${_timestamp}.tfplan"

    _access_key=$(terraform output access_key)
    _storage_account_name=$(terraform output storage_account_name)
    _container_name=$(terraform output container_name)
    _container_rg=$(terraform output arm_rg_name)

    ini_val "$config_file" terraform:generated.arm-access-key "$_access_key"
    ini_val "$config_file" terraform:generated.storage-account-name "$_storage_account_name"
    ini_val "$config_file" terraform:generated.container-name "$_container_name"
    ini_val "$config_file" terraform:generated.container-rg "$_container_rg"

    rm "$_timestamp.tfplan"

    popd || exit 2

    info "Created Storage Account $_storage_account_name for Terraform State"
}
# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function destroy_storage_account() {

    local _timestamp
    local _location
    local _subscription
    local _prefix
    local _storage_account_name
    local _container_name
    local _container_rg

    _timestamp=$(date "+%Y:%m:%d-%H:%M")


    info "Deleting Storage Account for Terraform State"

    pushd ../../components/infrastructure/azure/state-store/ || exit 2

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)

    terraform plan -destroy -out "${_timestamp}.tfplan" -var "location=$_location" -var "subscription_id=$_subscription" -var "prefix=$_prefix"
    terraform apply "${_timestamp}.tfplan"

    rm "$_timestamp.tfplan"
    rm -rf .terraform

    popd || exit 2

    info "Deleted Storage Account $_storage_account_name for Terraform State"
}
