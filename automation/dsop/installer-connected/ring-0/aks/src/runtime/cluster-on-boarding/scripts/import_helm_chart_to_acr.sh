#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# Imports a chart into ACR, overriding it if it already exists.
# Param 1 the URL of the source repository ie: https://charts.gitlab.io/
# Param 2 the name of the helm chart  ie: gitlab
# Param 3 the version of the helm chart: ie: gitlab 3.1.1
# Param 4 the name of the ACR wher the helm chart will be pushed
function import_chart_acr() {

    if [[ $# -ne 4 ]];
    then
		error "Missing input parameters"
        return 1
    fi

    tmp_dir="$(mktemp -d)"
    helm_source_repo="$1"
    helm_chart="$2"
    helm_chart_version="$3"
    acr_name="$4"

    info "Importing into ACR $acr_name chart $helm_chart with version $helm_chart_version from ${helm_source_repo} "

    #ACR requires that the chart is uploaded in .tgz so we have to pull it first.
    helm repo add temp "$helm_source_repo" 1>/dev/null
    tmp_helm_tar="${tmp_dir}"/"$helm_chart"-"$helm_chart_version".tgz
    helm pull temp/"$helm_chart" --version "$helm_chart_version" -d "$tmp_dir"

    az acr helm push --force -n "${acr_name}" "$tmp_helm_tar"
    helm repo remove temp 1>/dev/null
    rm "$tmp_helm_tar"
}
