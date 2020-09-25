#!/usr/bin/env bash


# fixes prefexes like E2E-AAD-Test -> e2eaadtestterraformstate which is needed to az storage names
# and trims to the max 24 chars limit ie MOREthank24CharPrexfi -> morethank24charprexfiter
function az_storage_normalize() {                                                                                                   
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._]//g' | sed 's/$/terraformstate&/' | cut -c -24
}

# Terraform Init - intialise a tf template + Azure Blob storage on Github action agent
function terraform_init_gh() {

    # shellcheck disable=SC2155
    local _storage_account_name="$(az_storage_normalize "$PREFIX")"
    local _container_name="${PREFIX}-terraform-state-sac"
    local _container_rg="${PREFIX}-c12-rg"
    local _subscription_id="$ARM_SUBSCRIPTION_ID"
    
    terraform init \
        -backend-config "storage_account_name=$_storage_account_name" \
        -backend-config "container_name=$_container_name" \
        -backend-config "resource_group_name=$_container_rg" \
        -backend-config "subscription_id=$_subscription_id"
}
