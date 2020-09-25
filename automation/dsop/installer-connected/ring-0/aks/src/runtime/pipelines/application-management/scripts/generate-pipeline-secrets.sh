#!/usr/bin/env bash

TOOLS_PATH="/app"


# shellcheck source=src/runtime/pipelines/application-management/scripts/terraform-utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terraform-utils.sh"


function generate-pipeline-secrets-actions() {

    set -euo pipefail
    pushd .c12/components/infrastructure/azure/aad_credentials_actions/
    chmod 777 ./post_grant_request.sh

    az login --service-principal -u "$ARM_CLIENT_ID" -p "$ARM_CLIENT_SECRET" -t "$ARM_TENANT_ID"

    #This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local ORG="$GITHUB_REPOSITORY_OWNER"

    APP_LIST_JSON=$("${TOOLS_PATH}"/appsourceextractor -a "${GITHUB_WORKSPACE}")
    APP_LIST=$(echo "$APP_LIST_JSON" | tail -1 | jq -r '.[]')
    echo "Apps found: $APP_LIST"


    _access_token="$PAT_TOKEN"
    _access_token_username="$PAT_USERNAME"
    _org="$ORG"
    _prefix="$PREFIX" 
    _subscription_id="$ARM_SUBSCRIPTION_ID"
    _ci_acr_name="$CI_ACR_NAME"
    _timestamp="$(date "+%Y-%m-%d_%H-%M")"

    _required_repos="archetype-management application-management"


    _repositories="["
    for repo in $_required_repos
    do
         _repositories=$_repositories"\"""$_prefix"-"$repo""\", "
    done
    for repo in $APP_LIST
    do
         _repositories=$_repositories"\"""$_prefix"-"$repo"'-src'"\", "
    done
    # Trim the last two charcaters
    _repositories="${_repositories%??}""]"
    echo "Repositories: ${_repositories}"
    
    terraform_init_gh


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


    if [ -z "${TF_DRY_RUN+set}" ];
    then
        terraform apply "${_timestamp}.tfplan"
    fi
    popd
}

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    generate-pipeline-secrets-actions
fi