#!/usr/bin/env bash


TOOLS_PATH="/app"

# shellcheck source=src/runtime/pipelines/application-management/scripts/git-utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/git-utils.sh"

function clone-all-repos-actions() {

    set -euo pipefail

    #This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local _org="$GITHUB_REPOSITORY_OWNER"
    local _prefix="$PREFIX"
    local _pat_username="$PAT_USERNAME"
    local _pat_password="$PAT_TOKEN"
    local _checkout_path="$GITHUB_WORKSPACE/cloned_repos"

    APP_LIST_JSON=$("${TOOLS_PATH}"/appsourceextractor -a "${GITHUB_WORKSPACE}")
    APP_LIST=$(echo "$APP_LIST_JSON" | tail -1 | jq -r '.[]')
    echo "Apps found: $APP_LIST"

    mkdir -p "$_checkout_path"
    pushd "$_checkout_path" || exit 3
    
    for app in $APP_LIST
    do
        clone-state-only-repo "$_org" "$_prefix" "$_pat_username" "$_pat_password" "$app"     
    done
    

    management_repos="archetype-management cluster-state cluster-management"
    # Iterate the string variable using for loop
    for repo in $management_repos; do
        repo_full_name="${PREFIX}-${repo}"
        clone-repo  "$repo_full_name" "$_pat_username" "$_pat_password" "$_org"
    done
    popd || exit 3

}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    clone-all-repos-actions
fi