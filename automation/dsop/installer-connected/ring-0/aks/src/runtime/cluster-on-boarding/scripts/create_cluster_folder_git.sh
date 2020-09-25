#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# Checks out the repository url received in Arg1 and creates a folder with the name of the cluster (Arg2)
# Arg1 the url of the git repository
# Arg2 the name of the clusteer
function create_folder_for_state_repo() {
    set -euo pipefail
    
    info "Creating folder in cluster-state repository for cluster"
    if [[ $# -ne 2 ]];
    then
        error "Expecting 2 arguments for this function"
        return 1
    fi

    git_url="$1"
    cluster_name="$2"

    tmp_dir="$(mktemp -d)"

    cluster_folder="$tmp_dir/$cluster_name"


    info "Clonning cluster state repo ($git_url) into $tmp_dir"
    git clone "$git_url" "$tmp_dir"


    # If the destination folder already contains the cluster folder
    # It most likely mean that the script failed before, but the folder was already commited
    if [[ -d "$cluster_folder" ]]; then
        warning "Folder in the cluster-state repository already exists, ovewriting contents"
        echo "$cluster_folder"
        return 0
    fi

    pushd "$tmp_dir" >/dev/null || return 2
    mkdir "$cluster_name"

    touch "$cluster_name"/.gitignore
    git add "$cluster_name"
    git commit -m "Onboarding: Add $cluster_name folder" >/dev/null

    info "Commiting folder to git"
    git push
    popd >/dev/null || return 2
    echo "$cluster_folder"
    return 0
}