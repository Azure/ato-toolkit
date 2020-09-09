#!/usr/bin/env bash

# shellcheck source=src/runtime/pipelines/application-management/scripts/terraform-utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terraform-utils.sh"


# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"


function generate-clone-repos-actions() {

    pushd .c12/components/infrastructure/repos/github-enterprise-cloud

    #This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local ORG="$GITHUB_REPOSITORY_OWNER"

    _application_names=$(get-application-list-json)
    _access_token="$PAT_TOKEN"
    _org="$ORG"
    _prefix="$PREFIX" 
    _applications="$_application_names"
    _timestamp="$(date "+%Y-%m-%d_%H-%M")"

    terraform_init_gh

    terraform plan \
    -lock=true \
    -out "${_timestamp}.tfplan" \
    -var "access_token=$_access_token" \
    -var "org=$_org" \
    -var "prefix=$_prefix" \
    -var "applications=$_applications"

    if [ -z "${TF_DRY_RUN+set}" ];
    then
        terraform apply "${_timestamp}.tfplan"
    fi
    popd
}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    generate-clone-repos-actions
fi