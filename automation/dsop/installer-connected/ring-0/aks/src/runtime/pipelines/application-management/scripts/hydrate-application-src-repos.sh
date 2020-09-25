#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"


# shellcheck source=src/runtime/pipelines/application-management/scripts/git-utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/git-utils.sh"

function push-content-to-application-src-repo() {

    cp -R "$_ci_solutions/." .        
    sed "s/%ORG%/$_org/; s/%REPO%/$app/; s/%PREFIX%/$_prefix/" < "$_ci_solutions/.github/CODEOWNERS" > CODEOWNERS

    git add -A
    git diff-index --quiet HEAD || git commit -a -m "Initial C12 Build Pipeline Import"        
    git push -u origin master
    echo "$_app_src_repo_path - CI Scripts Pushed Successfully"
}

function hydrate-application-src-repos-actions() {

    # This variables gets injected automatically by github actions docker type, declaring locals just for clarity of the code.
    local _prefix="$PREFIX"
    local _org="$GITHUB_REPOSITORY_OWNER"
    local _checkout_path="$GITHUB_WORKSPACE/cloned_repos"
    local _ci_solutions="$GITHUB_WORKSPACE/.c12/components/ci-solutions"
    local _pat_username="$PAT_USERNAME"
    local _pat_password="$PAT_TOKEN"
    _application_names=$(get-application-list)
    local _git_email="$GIT_EMAIL"
    local _git_name="$GIT_NAME"

   

    if [[ "$_application_names" == "" ]] 
    then
        echo "No applications found, nothing done"
        return 0
    fi

    git config --global user.email "$_git_email"
    git config --global user.name "$_git_name"

    for app in "${_application_names[@]}"; do
        cd "$_checkout_path"
        clone-src-only-repo "$_org" "$_prefix" "$_pat_username" "$_pat_password" "$app"     
        _app_src_repo_path="$_checkout_path/$_prefix-$app-src"
        if [ ! -f "$_app_src_repo_path/.github/workflows/application-src-pipeline.yml" ] || [ ! -f "$_app_src_repo_path/CODEOWNERS" ] || [ ! -d "$_app_src_repo_path/.c12" ]; then
            echo "$_app_src_repo_path - CI Scripts Missing"
            cd "$_app_src_repo_path"
            push-content-to-application-src-repo
            cd ..
        fi
    done
}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    hydrate-application-src-repos-actions
fi
