#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"


function generate_cluster_management_file() {

    info "Creating cluster management file"

    # Gather the login URL for ACR
    cluster_name=$(get_from_ini_or_error "$config_file" c12:generated.aks_name)
    acr_name=$(get_from_ini_or_error "$config_file" c12:generated.regional_acr_name)
    prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
    
    docker_registry_url=$(az acr show -n "${acr_name}" -o json | jq -r '.loginServer' | tr -d '\n')
    kubernetes_api_url=$(az aks get-credentials  -n "$cluster_name" -g "$prefix"-c12-rg -f - | grep 'server:' | cut -d' ' -f 6 | tr -d '\n')
    helm_registry_url="https://${docker_registry_url}/helm/v1/repo"
    
    cluster_file_contents=$(render_cluster_management_temaplate "$cluster_name" "$docker_registry_url" "$helm_registry_url" "$kubernetes_api_url") 
    cluster_file_path=/tmp/"$cluster_name".yaml
    
    echo "$cluster_file_contents" > "$cluster_file_path"  
    echo "$cluster_file_path"
}

# render_cluster_management_temaplate renders the cluster.yaml into the stdin
# Arg1 the name of the cluster
# Arg2 the docker registry
# Arg3 the helm chart registry URL
# Arg4 the URL of kubernetes API
function render_cluster_management_temaplate() {
 
    if [[ $# -ne 4 ]]
    then
        error "render_cluster_management_temaplete 4 arguments for this function"
        return 1
    fi

    cluster_name="$1" 
    docker_registry_url="$2"
    helm_registry_url="$3"
    kubernetes_api_url="$4"

    cluster_file_template="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../manifests/cluster-management-template.yaml"

    # the file contains the token to be replaced by the values.
    cluster_name=$cluster_name docker_registry_url=$docker_registry_url \
    helm_registry_url=$helm_registry_url  kubernetes_api_url=$kubernetes_api_url \
    envsubst < "$cluster_file_template"
}
