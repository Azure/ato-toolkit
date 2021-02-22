#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/tools.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

function upload_ssh_keys() {

    _timestamp="$(date "+%Y:%m:%d-%H:%M")"
    _cluster_name=$(get_from_ini_or_error "$config_file" "c12:generated.aks_name")
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _key="azure/aks.fluxadmin${_cluster_name}"
    _access_token=$(ini_val "$config_file" github.access-token)
    _org=$(ini_val "$config_file" github.org)
    _ssh_key_file_path=$(ini_val "$config_file" c12:generated.flux_ssh_key)
    _prefix=$(ini_val "$config_file" c12.prefix)

    pushd  "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/terraform/deploy_flux_key_github" || return 1    
    terraform init \
       -backend-config "storage_account_name=$_storage_account_name" \
       -backend-config "container_name=$_container_name" \
       -backend-config "resource_group_name=$_container_rg" \
       -backend-config "key=$_key" \
       -reconfigure

    terraform workspace select default

    terraform plan \
         -lock=true \
         -out "${_timestamp}.tfplan" \
         -var "prefix=$_prefix"\
         -var "access_token=$_access_token" \
         -var "org=$_org" \
         -var "ssh_pub_key=$_ssh_key_file_path" \
         -var "cluster_name=$_cluster_name"


    terraform apply "${_timestamp}.tfplan"

    popd || return 1
}