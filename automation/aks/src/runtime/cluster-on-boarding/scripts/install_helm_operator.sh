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

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"


DEF_HELM_OPERATOR_CHART_REPOSITORY="https://charts.fluxcd.io"
DEF_HELM_OPERATOR_CHART_CHART="helm-operator"
DEF_HELM_OPERATOR_CHART_VERSION="0.7.0"
DEF_HELM_OPERATOR_IMAGE_NAME="fluxcd/helm-operator"
DEF_HELM_OPERATOR_IMAGE_TAG="1.0.0-rc9"


# Imports a chart into ACR, overriding it if it already exists.
function install_helm_operator {

    # shellcheck disable=SC2154
    if [ -z "$config_file" ]
    then
        error "Configuration file argument not defined"
        exit 1
    fi

    flux_chart_repository="$DEF_HELM_OPERATOR_CHART_REPOSITORY"
    helm_operator_chart="$DEF_HELM_OPERATOR_CHART_CHART"
    helm_operator_chart_version="$DEF_HELM_OPERATOR_CHART_VERSION"
    helm_operator_image="$DEF_HELM_OPERATOR_IMAGE_NAME"
    helm_operator_image_version="$DEF_HELM_OPERATOR_IMAGE_TAG"

    naming_prefix=$(get_from_ini_or_error "$config_file" c12.prefix)
    acr_name=$(get_from_ini_or_error "$config_file" c12:generated.regional_acr_name)
    admin_namespace="$naming_prefix-c12-system"
    service_principal_application_id=$(get_from_ini_or_error "$config_file" c12:generated.service_principal_application_id)
    service_principal_password=$(get_from_ini_or_error "$config_file" c12:generated.service_principal_password)

    helm_operator_helm_release_manifest_url="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../manifests/flux-helm-release-crd.yaml"

    info "Creating helmrelease CRD"
    # Install the CRD for helmrelease (handled by helm operator)
    kubectl apply -f "${helm_operator_helm_release_manifest_url}"

    info "Importing helm operator "
    # Import the helm operator chart and required images into ACR
    import_image "${acr_name}" "${helm_operator_image}":"${helm_operator_image_version}"
    import_chart_acr "${flux_chart_repository}" "${helm_operator_chart}" "${helm_operator_chart_version}" "${acr_name}"

    # Gather the login URL for ACR
    login_server=$(az acr show -n "${acr_name}" -o json | jq -r '.loginServer' | tr -d '\n')

    helm_repos_yaml="$(mktemp)"

    # Render the secrets file needed by helm operator
    render_helm_repositories_template "$acr_name" "https://${login_server}/helm/v1/repo" "$service_principal_application_id" "$service_principal_password" > "$helm_repos_yaml"

    info "Creating credentials for HelmOperator in kubernetes"
    kubectl create secret generic flux-helm-repositories --namespace "${admin_namespace}" --from-file=repositories.yaml="$helm_repos_yaml" --dry-run -o yaml | kubectl apply  -f -
    rm -rf "$helm_repos_yaml"

    #install the helm operator through helm
    helm repo add tmprepo https://charts.fluxcd.io

    helm_operator_values_file="$(cd "$(dirname "${BASH_SOURCE[0]}")"  && pwd)/../manifests/helm-operator-install-values.yaml"
    helm_operator_release_name="$naming_prefix-c12-system-helm-operator"
    helm_operator_image_in_acr="tmprepo/$helm_operator_chart"

    info "Installing HelmOperator release:$helm_operator_release_name in namespace:$admin_namespace"
    #install the the helm operator
    helm upgrade -i \
    --set helm.versions=v3 \
    --set image.repository="$login_server/$helm_operator_image" \
    --set image.tag="$helm_operator_image_version" \
    --namespace "$admin_namespace" \
    -f "$helm_operator_values_file" \
    --wait \
    "$helm_operator_release_name" \
    "$helm_operator_image_in_acr"
}

# this function renders the template file that contains the list of repositories that helm operator will have acess to.
function render_helm_repositories_template() {

    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$4" ] || [ -z "$4" ]
    then
        error "input parameter not received"
        return 1
    fi

    name="$1"
    repo_url="$2"
    username="$3"
    password="$4"

    repositories_file_template="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../manifests/helm-repositories.yaml"

    #create the repositories.yaml that helm-operator requires
    name=${name} repo_url=${repo_url} username=${username} password=${password} \
    envsubst < "$repositories_file_template"

    return 0
 }