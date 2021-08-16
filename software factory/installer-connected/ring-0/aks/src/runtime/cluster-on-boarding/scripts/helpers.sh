#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/bootstrap/lib/ini_val.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/ini_val.sh"


function get_from_ini_or_error() {
    
    if [[ $# -ne 2 ]];
    then
        error "input parameter not received"
        return 1
    fi
    
    ini_file="$1"
    key="$2"

    if [ ! -f "$ini_file" ]; then
        error "Ini file with path $ini_file  not found"
        return 1
    fi

   
    val=$(ini_val "$ini_file" "$key")

    if [ -z "$val" ]; then
        error "$key not found in $ini_file, parameter not defined or missing value"
        return 1;
    fi

    echo "$val"
    return 0
}

function get_cluster_state_repo() {

   # shellcheck disable=SC2154
   org=$(get_from_ini_or_error "$config_file" github.org)
   prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
   echo "git@github.com:$org/$prefix-cluster-state.git"
   return 0
}

function  get_cluster_management_repo() {

   # shellcheck disable=SC2154
   org=$(get_from_ini_or_error "$config_file" github.org)
   prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
   echo "git@github.com:$org/$prefix-cluster-management.git"
   return 0
}



