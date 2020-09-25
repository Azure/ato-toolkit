#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"


function generate-application-admin-manifests() {

    # This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local _prefix="$PREFIX"
    local _app_definitions_path="$GITHUB_WORKSPACE"
    local _checkout_path="$GITHUB_WORKSPACE/cloned_repos"
    local _cluster_definitions_path="$_checkout_path/$_prefix-cluster-management"
    local _org="$GITHUB_REPOSITORY_OWNER"
    local _cluster_state_folder="$_checkout_path/$_prefix-cluster-state"
    # shellcheck disable=SC2154
    _application_names="$application_secret_mappings"

    for app_key in $(echo "${_application_names}" | jq -r '.[] | @base64'); do
        app=$( echo "${app_key}" | base64 --decode |  jq -r '.name')
        ssh_key=$( echo "${app_key}" | base64 --decode |  jq -r '.ssh_key')

        _app_state_repo_path="$_checkout_path/$_prefix-$app-state"
        echo "Generating Helm Release, Namespace for $app, using path: $_app_state_repo_path"
        "$TOOLS_PATH"/adminc12render -a "$_app_definitions_path"/"$app".yaml -c "$_cluster_definitions_path" -o "$_org" -p "$_prefix" -d "$_cluster_state_folder" -s "$ssh_key"
    done
}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    generate-application-admin-manifests
fi
