#!/usr/bin/env bash


# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"



# Reads all app.yaml and all the clusters.yaml and pushes the helm charts used by apps
# in the appropiate clusters, this version still does not support archetypes versions
function push_helm_chart_to_clusters() {

    # This variables are set by the github workflow when running the docker actions.
    local _prefix="$PREFIX"
    local _helm_username="$IMAGE_REPOSITORY_USERNAME"
    local _helm_password="$IMAGE_REPOSITORY_PASSWORD"
    local _ci_acr_name="$CI_ACR_NAME"

    repos_root="$GITHUB_WORKSPACE"
    cluster_definitions_path="$repos_root/cloned_repos/$_prefix-cluster-management"
    appplication_definitions_path="$repos_root"

    APP_LIST_JSON=$("$TOOLS_PATH"/chartextractor -a "$appplication_definitions_path" -c "$cluster_definitions_path")

    #Login in the source repository
    echo "Adding ci helm repository to local helm"
    helm repo add ci_acr https://"$_ci_acr_name".azurecr.io/helm/v1/repo --username "$_helm_username" --password "$_helm_password"

    # #Login in all required clusters helm registries, this is v2 OCI mode, hemloperator does not support it yet.
    # export HELM_EXPERIMENTAL_OCI=1
    # for clust in $(echo $JSON | jq -r 'flatten | unique | .[]')
    # do
    #     cluster_helm_repo_name="cluster_$clust"
    #     cluster_helm_repo=$(echo "$clusters_json" | jq -r ' . | select(.metadata.name=="'"$clust"'") | .spec.registry.helm.url' | tr -d "\n")
    #     echo "Login in $cluster_helm_repo"
    #     helm repo add "$cluster_helm_repo_name"  "$cluster_helm_repo" --username "$_helm_username" --password "$_helm_password"
    # done   
    
    #Create a temp repository for all the charts
    local _temp_folder
    _temp_folder=$(mktemp -d)

    #Loop over all the different achetypes used by the clusters
    for arch in $(echo "$APP_LIST_JSON" | jq -r "keys | .[]"); 
    do 
        echo "Pulling chart $arch from ci helm repository"
        helm pull ci_acr/"$arch" --destination "$_temp_folder"
        helm_chart_filename=$(find "$_temp_folder" -name "$arch*.tgz" | tr -d "\n")

        echo "Looking for all clusters where $arch is required ($helm_chart_filename)"

        #Go to each cluster where the archetype is required.
        for cluster in $(echo "$APP_LIST_JSON" | jq -r ".[\"$arch\"]? | .[]"); 
        do
            cluster_helm_repo=$(yq -r ' . | select(.metadata.name=="'"$cluster"'") | .spec.registry.helm.url' "$cluster_definitions_path"/*.yaml | tr -d "\n")
            echo "Cluster helm repository url: $cluster_helm_repo"
            acr_name=$(echo "$cluster_helm_repo" | grep --color=never -o -P '(?<=https://).*(?=\.azurecr\.io/helm/v1/repo)' | tr -d "\n")
           
            echo "pushing $arch to $cluster (using az cli to acr:$acr_name)"
            az acr helm push -n "$acr_name" "$helm_chart_filename" --force
        done
    done
}

set -euo pipefail

if [ -n "${GITHUB_ACTIONS+set}" ];
then
    az_cli_sp_login
    push_helm_chart_to_clusters
fi