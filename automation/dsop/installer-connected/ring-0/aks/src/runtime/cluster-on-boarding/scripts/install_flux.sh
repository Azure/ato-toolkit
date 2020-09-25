#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Catch the error in case any step of a pipe chain fails.
set -o pipefail

# shellcheck source=src/runtime/cluster-on-boarding/scripts/import_helm_chart_to_acr.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/import_helm_chart_to_acr.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/import_images.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/import_images.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/bootstrap/lib/ini_val.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/ini_val.sh"

DEF_HELM_OPERATOR_CHART_REPOSITORY="https://charts.fluxcd.io"
DEF_FLUX_IMAGE="fluxcd/flux"
DEF_FLUX_IMAGE_TAG="1.19.0"
DEF_FLUX_HELM_CHART="flux"
DEF_FLUX_HELM_CHART_VERSION="1.3.0"

function install_flux() {

    # shellcheck disable=SC2154
    if [ -z "$config_file" ]
    then
        error "Configuration file argument not defined"
        return 1
    fi

    flux_chart_repository="$DEF_HELM_OPERATOR_CHART_REPOSITORY"
    flux_image="$DEF_FLUX_IMAGE"
    flux_image_tag="$DEF_FLUX_IMAGE_TAG"

    flux_helm_chart="$DEF_FLUX_HELM_CHART"
    flux_helm_chart_version="$DEF_FLUX_HELM_CHART_VERSION"

    acr_name=$(get_from_ini_or_error "$config_file" c12:generated.regional_acr_name)
    naming_prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
    admin_namespace="$naming_prefix-c12-system"
    cluster_state_repo="$(get_cluster_state_repo)"
    cluster_name="$(get_from_ini_or_error "$config_file" c12:generated.aks_name)"

     # Gather the login URL for ACR
    login_server=$(az acr show -n "${acr_name}" -o json | jq -r '.loginServer' | tr -d '\n')

    helm_repo_url="https://${login_server}/helm/v1/repo"

    flux_imported_image_name=$(import_image "${acr_name}" "${flux_image}":"${flux_image_tag}")
    import_chart_acr "${flux_chart_repository}" "${flux_helm_chart}" "${flux_helm_chart_version}" "${acr_name}"

    # Render the secrets file needed by helm operator
    render_flux_helm_release "$admin_namespace" \
        "$helm_repo_url" \
        "$flux_helm_chart" \
        "$flux_helm_chart_version" \
        "$cluster_state_repo" \
        "$cluster_name" \
        "$flux_imported_image_name" \
        | kubectl apply -f -
}


# This function renders the HelmRelease cdr with the release for flux.
# Arg1 namespace where the helm release will be created and also the target namespace for the release
# Arg2 repo_url the url of the repo where the chart should be pulled from
# Arg3 chart_name the name of the chart to be installed
# Arg4 chart_version version of the flux chart to install
# Arg5 the url of the git repository to sync flux
# Arg6 the folder in the git repository for the cluster being synced
function render_flux_helm_release() {
    namespace=${1:?Required paramater not supplied}
    repo_url=${2:?Required paramater not supplied}
    chart_name=${3:?Required paramater not supplied}
    chart_version=${4:?Required paramater not supplied}
    git_repo_url=${5:?Required paramater not supplied}
    git_repo_folder=${6:?Required paramater not supplied}
    flux_image=${7:?Required paramater not supplied}

    release_file_template="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../manifests/flux-helm-release.yaml"

    # the file contains the token to be replaced by the values.
    namespace=${namespace} repo_url=${repo_url} chart_name=${chart_name} \
        chart_version=${chart_version} git_repo_url=${git_repo_url} git_repo_folder=${git_repo_folder} \
        flux_image=${flux_image} envsubst < "$release_file_template"

    return 0
 }
