#!/usr/bin/env bash
# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/tools.sh"

relative_terraform_path="../../components/infrastructure/azure/aad_credentials_actions/"
_required_repos="archetype-management application-management"

# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function aad_credentials_for_pipelines_create(){

    local _timestamp
    local _subscription_id
    local _prefix
    local _storage_account_name
    local _container_name
    local _container_rg
    local _access_token_username
    local _access_token
    local _org
    local _ci_acr_name


    _timestamp=$(date "+%Y:%m:%d-%H:%M")

    info "Creating SP and provision in GH as secret"

    pushd "$relative_terraform_path" || exit 2

    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token_username=$(ini_val "$config_file" github.access-token-username)
    _access_token=$(ini_val "$config_file" github.access-token)
    _org=$(ini_val "$config_file" github.org)
    _ci_acr_name=$(ini_val "$config_file" c12:generated.ci_acr_name)

    _repositories="["
    for repo in $_required_repos
    do
         _repositories=$_repositories"\"""$_prefix"-"$repo""\", "
    done
    # Trim the last two charcaters
    _repositories="${_repositories%??}""]"
    terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "subscription_id=$_subscription_id" \
        -var "prefix=$_prefix"\
        -var "org=$_org" \
        -var "access_token=$_access_token" \
        -var "access_token_username=$_access_token_username" \
        -var "repositories=$_repositories"\
        -var "ci_acr_name=$_ci_acr_name"

    terraform apply "${_timestamp}.tfplan"

    rm "$_timestamp.tfplan"

    popd || exit 2

    info "Service principal created and provisioned in github"
}

# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function aad_credentials_for_pipelines_destroy(){

    local _timestamp
    local _subscription_id
    local _prefix
    local _storage_account_name
    local _container_name
    local _container_rg
    local _access_token_username
    local _access_token
    local _org
    local _ci_acr_name

    _timestamp=$(date "+%Y:%m:%d-%H:%M")

    info "Destroying SP and GH secrets"

    pushd "$relative_terraform_path" || exit 2

    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token_username=$(ini_val "$config_file" github.access-token-username)
    _access_token=$(ini_val "$config_file" github.access-token)
    _org=$(ini_val "$config_file" github.org)
    _ci_acr_name=$(ini_val "$config_file" c12:generated.ci_acr_name)


    _repositories="["
    for repo in $_required_repos
    do
         _repositories=$_repositories"\"""$_prefix"-"$repo""\", "
    done
    # Trim the last two charcaters
    _repositories="${_repositories%??}""]"

    terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

    terraform plan \
        -lock=true \
        -destroy \
        -out "${_timestamp}.tfplan" \
        -var "subscription_id=$_subscription_id" \
        -var "prefix=$_prefix"\
        -var "org=$_org" \
        -var "access_token=$_access_token" \
        -var "access_token_username=$_access_token_username" \
        -var "repositories=$_repositories"\
        -var "ci_acr_name=$_ci_acr_name"

    terraform apply "${_timestamp}.tfplan"

    rm "$_timestamp.tfplan"
    rm -rf .terraform

    popd || exit 2

    info "Destroyed Service principal and GH secrets"
}
