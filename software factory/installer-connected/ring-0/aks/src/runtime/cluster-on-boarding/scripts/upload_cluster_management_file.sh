#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"


# This function checkouts the repository and adds the cluster folder to the root of the repository
# Arg1 the url of the cluster mangement state repository
# Arg2 the path of the cluster file to be uploaded to the repository
# Arg3 the cluster name, for commit message purposes
function upload_cluster_management_file() {


    if [[ $# -ne 3 ]];
    then
        error "upload_cluster_management_file 2 arguments for this function"
        return 1
    fi

    info "Creating folder in cluster-state repository for cluster"

    git_url="$1"
    cluster_file_path="$2"
    cluster_name="$3"
    tmp_dir="$(mktemp -d)"

    info "Clonning cluster state repo ($git_url) into $tmp_dir"
    git clone "$git_url" "$tmp_dir"

    pushd "$tmp_dir" >/dev/null || return 2

    cp "$cluster_file_path" "$tmp_dir"

    git add "."
    git diff-index --quiet HEAD || git commit -m "Onboarding: Add $cluster_name" >/dev/null

    info "Commiting folder to git"
    git push
    popd >/dev/null || return 2
    rm -rf "$tmp_dir"
    return 0
}