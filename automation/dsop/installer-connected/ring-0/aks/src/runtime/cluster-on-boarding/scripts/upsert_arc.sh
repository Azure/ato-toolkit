#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

ARC_CLUSTER_CONFIG_NAME="cluster-config"
ARC_CLUSTER_TYPE="managedclusters"

DEF_HELM_OPERATOR_CHART_REPOSITORY="https://charts.fluxcd.io"
DEF_FLUX_HELM_CHART="flux"
DEF_FLUX_HELM_CHART_VERSION="1.3.0"
DEF_FLUX_IMAGE="fluxcd/flux"
DEF_FLUX_IMAGE_TAG="1.19.0"


# Allows time for  Arc Config Agent to fully initialize and generate flux ssh key
function monitor_arc_setup() {

    info "Polling for the status of of Azure Arc Config Agent to fully initialize"
    conclusion="temp"
    while [[ "$conclusion" = "temp" ]]
    do
	    # shellcheck disable=SC2154
        result=$(az k8sconfiguration show --resource-group "$rg" \
					--cluster-name "$cluster_name" \
					--name "$ARC_CLUSTER_CONFIG_NAME" \
					--cluster-type "$ARC_CLUSTER_TYPE" \
					-o json | jq -r '.complianceStatus.complianceState' | tail -1)        
        info "Arc Config Agent initialization is $result"
        if [[ "$result" == "Installed" ]]
        then
            conclusion=$result
        else
            sleep 10
        fi
    done
    info "Arc Config Agent initialization is now $conclusion" 
	az k8sconfiguration show --resource-group "$rg" \
			--cluster-name "$cluster_name" \
			--name "$ARC_CLUSTER_CONFIG_NAME" \
			--cluster-type "$ARC_CLUSTER_TYPE" \
			-o json 
}


function install_arc_config_agent() {

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _tenantId=$(az account list -o json | jq -r --arg SUB_ID "${_subscription}" '.[] | select( .id == $SUB_ID ) | .tenantId')
	_prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
	cluster_state_repo="$(get_cluster_state_repo)"
	
	# Installing the Azure ARC Kubernetes configuration agent
	helm repo add azurearcfork8s https://azurearcfork8s.azurecr.io/helm/v1/repo

	helm upgrade azure-k8s-config azurearcfork8s/azure-k8s-config --install \
	--set global.subscriptionId="$_subscription",global.resourceGroupName="$rg" \
	--set global.resourceName="$cluster_name",global.location="$_location" \
	--set global.tenantId="$_tenantId"


	az k8sconfiguration create --resource-group "$rg" \
			--cluster-name "$cluster_name" \
			--cluster-type managedclusters \
			--name cluster-config \
			--operator-instance-name "${_prefix}-c12-system" \
			--operator-namespace "${_prefix}-c12-system" \
			--enable-helm-operator false \
    		--repository-url "${cluster_state_repo}" \
			--operator-params "--git-readonly --git-path ${cluster_name} --git-poll-interval=30s --registry-disable-scanning" \
			--scope cluster

}


# Optains Flux SSH key from k8sconfiguration expose command and saves in temp file and c12.ini for later uses.
function get_flux_key_from_arc() {
	
	ssh_key=$(az k8sconfiguration show --resource-group "$rg" \
			--cluster-name "$cluster_name" \
			--name "$ARC_CLUSTER_CONFIG_NAME" \
			--cluster-type "$ARC_CLUSTER_TYPE" \
			--query 'repositoryPublicKey' -o json | jq -r '.')
 
    ssh_key_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/flux_id_rsa.pub"

    echo "$ssh_key" > "$ssh_key_path"

    ini_val "$config_file" c12:generated.flux_ssh_key "$ssh_key_path"
}

function import_app_flux_to_cluster_acr() {

    acr_name=$(get_from_ini_or_error "$config_file" c12:generated.regional_acr_name)
	
    import_image "${acr_name}" "${DEF_FLUX_IMAGE}":"${DEF_FLUX_IMAGE_TAG}"
	import_chart_acr "${DEF_HELM_OPERATOR_CHART_REPOSITORY}" "${DEF_FLUX_HELM_CHART}" "${DEF_FLUX_HELM_CHART_VERSION}" "${acr_name}"
}

# Creates Arc nessary Dependencies in cluster and connects cluster to Azure
function upsert_arc() {
	# import flux image into cluster ACR, nessary for Application flux instances 
	import_app_flux_to_cluster_acr

	# install ARC Agent helm chart and provision.
	install_arc_config_agent

	# Wait for ARC Agent to fully initialize before requesting Flux SSH key.
	monitor_arc_setup
	get_flux_key_from_arc
}