#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

# This functions iterates over the rbac folder, and for each file found
# It gets from the .ini file the ${prefix}_group_id.  ${prefix} being the file name in rbac
# then renders the file and copies it to the cluster folder, defined by Arg1
# then it commits git and pushes the changes.
# Arg1 the cluster-state folder where the rbac files render will be added.
function render_and_copy_rbac {

    if [[ $# -ne 1 ]];
    then
        error "Expecting 1 arguments for this function"
        return 1
    fi

    cluster_folder="$1"
    info "Adding RBAC files to $cluster_folder"
    
    rbac_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/manifests/rbac/*"
    for f in $rbac_folder
    do
        info "Processing $f "
        local_file_name="$(basename -- "${f}")"
        role_name=${local_file_name%.*}
        groupid=$(ini_val "$config_file" c12:generated."${role_name}"_group_id )
        groupObjectId=$groupid envsubst < "$f" > "$cluster_folder"/"$local_file_name"
    done

    pushd "$cluster_folder" >/dev/null || return 1    
  
    cd ..
    info "Commiting rbac settings for rbac"
    git add .
    git commit -m "Onboarding: Add rbac files" || true
    git push 
    popd >/dev/null || return 1
}