#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

function generate-app-helm-releases() {

    # This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local _prefix="$PREFIX"
    local _app_definitions_path="$GITHUB_WORKSPACE"
    local _checkout_path="$GITHUB_WORKSPACE/cloned_repos"
    local _cluster_definitions_path="$_checkout_path/$_prefix-cluster-management"
    local _org="$GITHUB_REPOSITORY_OWNER"

    _application_names=$(get-application-list)
    echo "Applications found '$_application_names'"

    if [[ "$_application_names" == "" ]] 
    then
        echo "No applications found, nothing done"
        return 0
    fi
   
    for app in "${_application_names[@]}"; do
        _app_state_repo_path="$_checkout_path/$_prefix-$app-state"
        echo "Generating Helm Release, Namespace for $app, using path: $_app_state_repo_path"
        "$TOOLS_PATH"/apprendering -a "$_app_definitions_path"/"$app".yaml -c "$_cluster_definitions_path" -p "$_prefix" -d "$_app_state_repo_path" -o "$_org"
    done

    tree "$_checkout_path"
}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    generate-app-helm-releases
fi