#!/usr/bin/env bash

# shellcheck source=src/runtime/pipelines/application-management/scripts/utils.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/utils.sh"

function push-docker-images() {

    # This variables are assigned by the workflow when running as an action, specified here as locals for clarity.
    local _org="$GITHUB_REPOSITORY_OWNER"
    local _prefix="$PREFIX"
    local _appplication_definitions_path="$GITHUB_WORKSPACE"
    local _cluster_definitions_path="$GITHUB_WORKSPACE/cloned_repos/$_prefix-cluster-management"
    local _application_names
    local _ci_acr_name="$CI_ACR_NAME"
    
    _application_names=$(get-application-list)

    _all_acr=$(az acr list -o json)
    _ci_acr_login_url=$(az acr list | jq -r ' .[] | select(.name == "'"$_ci_acr_name"'") | .loginServer' | tr -d "\n" )

    for _app_name in $_application_names
    do
        echo "Provisioning images for $_app_name"
        _app_definition_path="$_appplication_definitions_path"/"$_app_name".yaml
        for _deployment_group in $(yq -r '.spec."deployment-groups"[].name' "$_app_definition_path")
        do
            echo "Pushing images of $_deployment_group"
            _app_version=$(yq -r '.spec."deployment-groups"[]  | select(.name=="'"$_deployment_group"'") | .application.version ' "$_app_definition_path")
            if [[ "$_app_version" == "null" ]]
            then
                echo "Skipping image push of app $_app_name for deployment group $_deployment_group application version is null"
            else
                echo "Version for deployment group is $_app_version"
                source_image="$_ci_acr_login_url"/"$_org"/"$_prefix"-"$_app_name"-src:"$_app_version"
                
                for cluster in $(yq -r '.spec."deployment-groups"[]  | select(.name=="'"$_deployment_group"'") | .clusters[].name ' "$_app_definition_path")
                do
                    echo "Pushing $_app_name version: $_app_version to cluster: $cluster"
                    cluster_acr_registry_url=$(yq -r ' . | select(.metadata.name=="'"$cluster"'") | .spec.registry.docker.url' "$_cluster_definitions_path"/*.yaml | tr -d "\n")
                    cluster_acr_azure_name=$(echo "$_all_acr" | jq -r ' .[] | select( .loginServer == "'"$cluster_acr_registry_url"'") | .name' | tr -d "\n" )
                    echo "destination: ${cluster_acr_azure_name} source image: ${source_image}"
                    az acr import --force -n "${cluster_acr_azure_name}" --source "$source_image"
                done
            fi            
        done        
    done
}

set -euo pipefail


if [ -n "${GITHUB_ACTIONS+set}" ];
then
    az_cli_sp_login
    push-docker-images
fi