#!/usr/bin/env bash


function clone-repo() {
    
    local _repo_name    
    local _pat_username

    _repo_name="$1"
    _pat_username="$2"
    _pat_password="$3"
    _github_repository_owner="$4"


    git_url="https://${_pat_username}:${_pat_password}@github.com/$_github_repository_owner/$_repo_name.git"

    echo "Cloning: $_repo_name"    

    git clone "$git_url"
    pushd "$_repo_name" || exit 2
    git config --local gc.auto 0
    popd || exit 2
}

function clone-state-only-repo() {
    set -euo pipefail
    
    local _org="$1"
    local _pat_username="$3"
    local _pat_password="$4"
    local _app_name="$5"

    # clone clone application state/source repos
    echo "Clonning state app with name: '$_app_name'"
    repo_name="${PREFIX}-${_app_name}-state"
    clone-repo  "$repo_name" "$_pat_username" "$_pat_password" "$_org"    
}

function clone-src-only-repo() {
    set -euo pipefail
    
    local _org="$1"
    local _pat_username="$3"
    local _pat_password="$4"
    local _app_name="$5"

    # clone clone application state/source repos
    echo "Clonning src app with name: '$_app_name'"
    repo_name="${PREFIX}-${_app_name}-src"
    clone-repo  "$repo_name" "$_pat_username" "$_pat_password" "$_org"    
}
