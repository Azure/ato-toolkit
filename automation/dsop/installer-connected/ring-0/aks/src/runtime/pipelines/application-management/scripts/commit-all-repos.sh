#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

function commit-all-repos() {
    
   # This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local _checkout_path="$GITHUB_WORKSPACE/cloned_repos"
    local _git_email="$GIT_EMAIL"
    local _git_name="$GIT_NAME"

    git config --global user.email "$_git_email"
    git config --global user.name "$_git_name"

    temp_dir=$(mktemp -d)

    mv "$_checkout_path" "$temp_dir"

    pushd "$temp_dir/cloned_repos" || exit 2
    while IFS= read -r d; do 
        commit-repo "$d"
    done < <(find -- * -maxdepth 0 -type d)
    popd || exit 2

    mv "$temp_dir/cloned_repos" "$GITHUB_WORKSPACE"

}

function commit-repo() {
    local _repo="$1"

    echo "Commiting $_repo"
    pushd "$_repo" || exit 2
    if [ -z "$(git status --porcelain)" ]; then 
        # Working directory clean
        echo "No changes in $_repo"
    else 
        # Uncommitted changes
        git add -A;
        git commit -m "application-management ci"
        git push    
    fi
    popd || exit 2

}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    commit-all-repos
fi