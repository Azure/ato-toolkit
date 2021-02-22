#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -euo pipefail

# shellcheck disable=SC2034
read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
  -f --file [arg]  Config Filename to use.
  -v               Enable verbose mode, print script as it is executed
  -d --debug       Enables debug mode
  -h --help        This page
  -n --no-color    Disable color output
EOF

## Boilerplate files
# shellcheck source=src/runtime/bootstrap/lib/main.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/main.sh"

# shellcheck source=src/runtime/bootstrap/lib/ini_val.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/ini_val.sh"


# shellcheck source=src/runtime/cluster-on-boarding/scripts/install_flux.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install_flux.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/install_helm_operator.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install_helm_operator.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/render_azure_service_operator.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/render_azure_service_operator.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/create_cluster_folder_git.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/create_cluster_folder_git.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/render_and_copy_rbac.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/render_and_copy_rbac.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/render_and_copy_cert_manager.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/render_and_copy_cert_manager.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/upsert_namespace.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/upsert_namespace.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/get_flux_ssh_keys.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/get_flux_ssh_keys.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/upload_ssh_keys.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/upload_ssh_keys.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/upload_cluster_management_file.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/upload_cluster_management_file.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/create_cluster_management_file.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/create_cluster_management_file.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/upsert_arc.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/upsert_arc.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/configure_storage_classes.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/configure_storage_classes.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/configure_gatekeeper.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/configure_gatekeeper.sh"



### Validation. Error out if the things required for your script are not present
##############################################################################

[[ "${arg_f:-}" ]]     || help      "Setting a filename with -f or --file is required"
[[ "${LOG_LEVEL:-}" ]] || emergency "Cannot continue without LOG_LEVEL. "

config_file="$arg_f"
info "Reading $config_file for configuration"

jumphost_user=$(get_from_ini_or_error "$config_file" c12:generated.jumphost_user)
jumphost_ip=$(get_from_ini_or_error "$config_file" c12:generated.jumphost_ip)
jumphost_ssh_key_location=$(get_from_ini_or_error "$config_file" c12:generated.jumphost_ssh_key_location)
info "Creating SSH Tunnel"
ssh -oStrictHostKeyChecking=no "$jumphost_user"@"$jumphost_ip" -i "$jumphost_ssh_key_location" -L 1234:127.0.0.1:8888 -C -N &

# These env vars are used by helm / kubectl to talk to the K8S API server via the jumphost
# shellcheck disable=SC2034
export HTTPS_PROXY=http://127.0.0.1:1234
# shellcheck disable=SC2034
export https_proxy=http://127.0.0.1:1234

prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
namespace="$prefix-c12-system"
flux_release_name="$namespace-flux"
git_cluster_state=$(get_cluster_state_repo)
cluster_name=$(get_from_ini_or_error "$config_file" c12:generated.aks_name)
rg=$(get_from_ini_or_error "$config_file" terraform:generated.container-rg)
disk_encryption_set_id=$(ini_val "$config_file" c12:generated.disk_encryption_set_id)

az aks get-credentials --resource-group "$rg" --name "$cluster_name" --admin --overwrite-existing

debug "namespace:$namespace flux_release_name:$flux_release_name git_cluster_state:$git_cluster_state"


# First step is create the folder in the cluster-state and add all the required manifests
# We keep the local folder of the cluster for installing rbac later.
cluster_state_folder=$(create_folder_for_state_repo "$git_cluster_state" "$cluster_name") 
render_and_copy_rbac "$cluster_state_folder"

#Create the storage classes with encrypted disk sets and delete any other
configure_storage_classes "$disk_encryption_set_id"

configure_gatekeeper "$cluster_state_folder"

# Install the cert-manager components and CRDs
acr_name=$(get_from_ini_or_error "$config_file" c12:generated.regional_acr_name)
render_and_copy_cert_manager "$cluster_state_folder"
import_image "$acr_name" "quay.io/jetstack/cert-manager-cainjector:v0.14.3"
import_image "$acr_name" "quay.io/jetstack/cert-manager-controller:v0.14.3"
import_image "$acr_name" "quay.io/jetstack/cert-manager-webhook:v0.14.3"


#  Renders the azure-service-operator's HelmRelease
#  Generates sufficient Service Principal for ASO
#  Transfers required Images to Cluster ACR
render_azure_service_operator "$cluster_state_folder"


# if the feature flag for Azure Arc is `true` will on board with ARC Config Agent.
# shellcheck disable=SC2086
if [[ "$(ini_val $config_file azure.arc-support)" == "true" ]]; then
  # Install Azure Arc and connect to ARC Config Agent and obtain Flux SSH key
  info "Connect cluster to Azure ARC Config Agent"
  upsert_arc
  info "Cluster Successfully Connect Azure ARC Config Agent"
  # Install helm operator and flux
  info "Installing HelmOperator in the cluster"
  install_helm_operator
  # Upload the SSH keys generated by flux using terraform into the state repository so the cluster
  info "Granting permissions to flux in cluster-state repository"
  upload_ssh_keys
else
  # Install helm operator and flux
  info "Installing HelmOperator and Flux in the cluster"
  upsert_namespace "$namespace"
  install_helm_operator
  install_flux

  # Upload the SSH keys generated by flux using terraform into the state repository so the cluster
  # can perform the pull
  info "Granting permissions to flux in cluster-state repository"
  get_flux_ssh_keys "$namespace" "$flux_release_name"
  upload_ssh_keys
fi

cluster_file_path=$(generate_cluster_management_file)
cluster_namagement_git=$(get_cluster_management_repo)
upload_cluster_management_file "$cluster_namagement_git" "$cluster_file_path" "$cluster_name"



info "Cluster successfully onboarded"

for job in $(jobs -l "%ssh"  | cut -d' ' -f 2)
do
    kill "$job"
done
unset HTTPS_PROXY
unset https_proxy
