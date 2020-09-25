#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/terraform-utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terraform-utils.sh"

# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

function generate-deploy-keys-actions() {
    pushd .c12/components/infrastructure/repos/deploy-keys

    #This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local ORG="$GITHUB_REPOSITORY_OWNER"
    _application_names=$(get-application-list-json)

    echo "Applications found: $_application_names"

    _subscription_id="$ARM_SUBSCRIPTION_ID"
    _prefix="$PREFIX" 
    _applications="$_application_names"
    _access_token="$PAT_TOKEN"
    _org="$ORG"

    _timestamp="$(date "+%Y-%m-%d_%H-%M")"

    terraform_init_gh

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "subscription_id=$_subscription_id" \
        -var "org=$_org" \
        -var "access_token=$_access_token" \
        -var "prefix=$_prefix" \
        -var "applications=$_applications"

    if [ -z "${TF_DRY_RUN+set}" ];
    then
        terraform apply "${_timestamp}.tfplan"

        # get generated keys from Terraform to deploy to app-states.
        _app_keys=$( terraform output -json | jq -c '."application-secret-mappings".value' )
        echo "_app_keys: $_app_keys" 
        # sets as ENV var for next task in pipeline
        echo "::set-env name=application_secret_mappings::$_app_keys"
    fi
    popd

}


set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    generate-deploy-keys-actions
fi