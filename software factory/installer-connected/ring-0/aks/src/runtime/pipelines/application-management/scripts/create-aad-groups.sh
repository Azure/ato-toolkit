#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/terraform-utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/terraform-utils.sh"

# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"


function create-aad-groups-actions() {
    set -euo pipefail
    pushd .c12/components/identity-providers/aad

    #This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local ORG="$GITHUB_REPOSITORY_OWNER"
    _application_names=$(get-application-list-json)


    _subscription_id="$ARM_SUBSCRIPTION_ID"
    _prefix="$PREFIX" 
    _applications="$_application_names"
    _timestamp="$(date "+%Y-%m-%d_%H-%M")"

    terraform_init_gh

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "subscription_id=$_subscription_id" \
        -var "prefix=$_prefix" \
        -var "applications=$_applications"

    if [ -z "${TF_DRY_RUN+set}" ];
    then
        terraform apply "${_timestamp}.tfplan"
    fi
    popd
}
function create-github-teams-actions() {
    set -euo pipefail
    pushd .c12/components/infrastructure/teams/github-enterprise-cloud

    # avoid getting (local-exec): /bin/sh: : Permission denied on agent
    chmod 777 ./delete-teams.sh
    #This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local ORG="$GITHUB_REPOSITORY_OWNER"
    _application_names=$(get-application-list-json)

    _subscription_id="$ARM_SUBSCRIPTION_ID"
    _prefix="$PREFIX" 
    _applications="$_application_names"
    _timestamp="$(date "+%Y-%m-%d_%H-%M")"
    _access_token="$PAT_TOKEN"
    _org="$ORG"

    terraform_init_gh

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "access_token=$_access_token" \
        -var "org=$_org" \
        -var "access_token=$_access_token" \
        -var "subscription_id=$_subscription_id" \
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
    create-aad-groups-actions

    # running into a fauilure in e2e where planing will fail as AAD Groups not created yet
    if [ -z "${TF_DRY_RUN+set}" ];
    then
        create-github-teams-actions
    fi
fi