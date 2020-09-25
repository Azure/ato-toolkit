#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/tools.sh"

relative_ci_docker_image="../ci-tooling"
docker_ci_image_name="c12/ci-tooling"
docker_ci_image_tag="latest"

function push_docker_image() {

    acr_name="$1"
    docker_image_repository="$2"

    #echo -n "$docker_image_repository_passwd" | docker login "$docker_image_repository" --username "$docker_image_repository_username" --password-stdin
    az acr login -n "$acr_name"

    docker push "$docker_image_repository"/"$docker_ci_image_name":"$docker_ci_image_tag"
}

function build_docker_image() {

    image_full_name="$1"

    pushd "$relative_ci_docker_image"  || exit 2
    docker build -t "$image_full_name" .
    popd  || exit 2
}

function provision_ci_docker_image() {
    # shellcheck disable=SC2154
    ci_acr_name=$(ini_val "$config_file" c12:generated.ci_acr_name)
    docker_image_repository="$(az acr show --n "$ci_acr_name" -o json | jq -r '.loginServer' | tr -d '\n')"
    image_full_name="$docker_image_repository"/"$docker_ci_image_name":"$docker_ci_image_tag"

    build_docker_image "$image_full_name"
    push_docker_image "$ci_acr_name" "$docker_image_repository"
}