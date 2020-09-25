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
function render_and_copy_cert_manager {

    if [[ $# -ne 1 ]];
    then
        error "Expecting 1 arguments for this function"
        return 1
    fi

    cluster_folder="$1"
    info "Adding cert-manager files to $cluster_folder"

    info "Processing rendering cert-manager-template.yaml "
    acr=$(ini_val "$config_file" c12:generated.regional_acr_name )
    acr=$acr envsubst < "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/manifests/cert-manager-template.yaml" > "$cluster_folder/cert-manager.yaml"


    pushd "$cluster_folder" >/dev/null || return 1
    cd ..

    info "Commiting settings for cert-manager"
    git add .
    git commit -m "Onboarding: Add cert-manager" || true
    git push
    popd >/dev/null || return 1
}