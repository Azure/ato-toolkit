#!/usr/bin/env bash

# shellcheck disable=SC2034
read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
  -f --file [arg]  Config Filename to use. Default="./c12.ini"
  -v               Enable verbose mode, print script as it is executed
  -g --generate-config-example Generate a config file example
  -d --debug       Enables debug mode
  -h --help        This page
  -n --no-color    Disable color output
  -D --delete      Delete C12
EOF

# shellcheck disable=SC2034
read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
 This script bootstraps a C12 environment for evaluation and testing.
 Examine the README.md file to see the resources it creates.

 To get started run './bootstrap --generate-config-example' and update the values
 in c12.ini
EOF
## Boilerplate files
# shellcheck source=src/runtime/bootstrap/lib/main.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/main.sh"
# shellcheck source=src/runtime/bootstrap/lib/ini_val.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/ini_val.sh"

## Component Files
# These contain the bash scripts to run the create / delete / update for each
# bootstrap step
# shellcheck source=src/runtime/bootstrap/steps/terraform_storage_account.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps/terraform_storage_account.sh"

# shellcheck source=src/runtime/bootstrap/steps/terraform_network.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps/terraform_network.sh"

# shellcheck source=src/runtime/bootstrap/steps/terraform_aks.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps/terraform_aks.sh"

# shellcheck source=src/runtime/bootstrap/steps/terraform_aad_credentials_pipeline.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps/terraform_aad_credentials_pipeline.sh"

# shellcheck source=src/runtime/bootstrap/steps/provision_ci_docker_images.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps/provision_ci_docker_images.sh"

# shellcheck source=src/runtime/bootstrap/steps/populate-repos.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/steps/populate-repos.sh"

### Validation. Error out if the things required for your script are not present
##############################################################################

[[ "${arg_f:-}" ]]     || help      "Setting a filename with -f or --file is required"
[[ "${LOG_LEVEL:-}" ]] || emergency "Cannot continue without LOG_LEVEL. "

config_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$arg_f"
debug "expanding config file to $config_file"

# debug mode
if [[ "${arg_d:?}" = "1" ]]; then
  set -o xtrace
  PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  LOG_LEVEL="7"
  # Enable error backtracing
  trap '__b3bp_err_report "${FUNCNAME:-.}" ${LINENO}' ERR
fi

# verbose mode
if [[ "${arg_v:?}" = "1" ]]; then
  set -o verbose
fi

# no color mode
if [[ "${arg_n:?}" = "1" ]]; then
  NO_COLOR="true"
fi

# help mode
if [[ "${arg_h:?}" = "1" ]]; then
  # Help exists with code 1
  help "Help using ${0}"
fi

### Runtime
##############################################################################


set -e


function destroy() {
    aad_credentials_for_pipelines_destroy
    destroy_aks
    destroy_network
    github_teams_delete
    aad_groups_delete
    github_repos_delete
    destroy_storage_account
    rm -rf ../cluster-on-boarding/terraform/.terraform
}


function generate_config() {
  # Azure info
  ini_val "$config_file" azure.subscription "<subscription id>" "ID of the subscription used for the C12 components"
  ini_val "$config_file" azure.location "<location id>" "ID of the location used for the C12 components"
  ini_val "$config_file" azure.arc-support "false" "[PREVIEW] See README for more info."
  # C12 info
  ini_val "$config_file" c12.prefix "<prefix>" "Prefix to use for names within the C12 deployments"
  ini_val "$config_file" c12:bootstrap.phase "bootstrap-config-generated" "Phase of C12 bootstrap - do not manually edit"

  # Github info
  ini_val "$config_file" github.org "<github org>" "GitHub org to use for C12 repos and co-ordination"
  ini_val "$config_file" github.access-token "<access token>" "GitHub Personal Access Token Used to manage the GitHub Organisation "
  ini_val "$config_file" github.access-token-username "<github username>" "GitHub username that was used to generate the access-token"
}


function aad_groups_create(){
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token=$(ini_val "$config_file" github.access-token)
    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)
    # shellcheck disable=SC2154
    "$__dir"/../../components/identity-providers/aad/upsert-groups.sh \
        "$_storage_account_name" \
        "$_container_name" \
        "$_container_rg" \
        "$_subscription_id" \
        "$_prefix" \
        null \
        "$config_file"
}

function aad_groups_delete(){
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token=$(ini_val "$config_file" github.access-token)
    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)
    "$__dir"/../../components/identity-providers/aad/delete-groups.sh \
        "$_storage_account_name" \
        "$_container_name" \
        "$_container_rg" \
        "$_subscription_id" \
        "$_prefix" \
        "[\"sample-app-nodejs\"]"
}

# shellcheck disable=SC2086
function github_repos_create() {
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token=$(ini_val "$config_file" github.access-token)
    _org=$(ini_val "$config_file" github.org)
    _prefix=$(ini_val "$config_file" c12.prefix)
    "$__dir"/../../components/infrastructure/repos/github-enterprise-cloud/upsert-repos.sh \
        "$_storage_account_name" \
        "$_container_name" \
        "$_container_rg" \
        "$_access_token" \
        "$_org" \
        "$_prefix" \
        null
}

# shellcheck disable=SC2086
function github_repos_delete() {
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token=$(ini_val "$config_file" github.access-token)
    _org=$(ini_val "$config_file" github.org)
    _prefix=$(ini_val "$config_file" c12.prefix)
    "$__dir"/../../components/infrastructure/repos/github-enterprise-cloud/delete-repos.sh \
        "$_storage_account_name" \
        "$_container_name" \
        "$_container_rg" \
        "$_access_token" \
        "$_org" \
        "$_prefix" \
        "[\"sample-app-nodejs\"]"
}
# shellcheck disable=SC2086
function github_teams_create() {
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token=$(ini_val "$config_file" github.access-token)
    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _org=$(ini_val "$config_file" github.org)
    _prefix=$(ini_val "$config_file" c12.prefix)
    "$__dir"/../../components/infrastructure/teams/github-enterprise-cloud/upsert-teams.sh \
        "$_storage_account_name" \
        "$_container_name" \
        "$_container_rg" \
        "$_access_token" \
        "$_subscription_id" \
        "$_org" \
        "$_prefix" \
        null
}

function github_teams_delete() {
    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)
    _access_token=$(ini_val "$config_file" github.access-token)
    _subscription_id=$(ini_val "$config_file" azure.subscription)
    _org=$(ini_val "$config_file" github.org)
    _prefix=$(ini_val "$config_file" c12.prefix)
    "$__dir"/../../components/infrastructure/teams/github-enterprise-cloud/delete-teams.sh \
        "$_storage_account_name" \
        "$_container_name" \
        "$_container_rg" \
        "$_access_token" \
        "$_subscription_id" \
        "$_org" \
        "$_prefix" \
        "[\"sample-app-nodejs\"]"
}

function hydrate_repos() {
     populate-repos "$config_file"
}

function adopt_cluster() {
    "$__dir"/../cluster-on-boarding/scripts/on_board_cluster.sh -f "$config_file"
}

function test_config() {
    warning "test_config not implemented yet. Only turning Github org string to lowercase if needed for now."
    info "./validate-config.sh"

    current_org=$(ini_val "$config_file" github.org)
    # shellcheck disable=SC2020
    lowercase_org="$(echo "$current_org" | tr '[:upper:]' '[:lower:]')"

    if [[ $current_org != "$lowercase_org" ]]; then
        # Turning Github org string to lowercase and writing it back to .ini file to avoid error creating repos
        ini_val "$config_file" github.org "$lowercase_org"
        warning "Github org value in .ini file was turned to lowercase (to create valid repo names)."

    fi
}

if [[ "${arg_g:?}" = "1" ]]; then
  # Help exists with code 1
  info "Generating sample config file in $config_file"
  generate_config
  exit 0
fi

if [[ "${arg_D:?}" = "1" ]]; then
  # Help exists with code 1
  warning "Destroying C12 infrastructure"
  destroy
  exit 0
fi

# shellcheck disable=SC2086
if [[ "$(ini_val $config_file azure.arc-support)" == "true" ]]; then
  # Check if location is support for Azure Arc
  _location=$(ini_val "$config_file" azure.location)
  _supported_locations="eastus westeurope"
  _supported="false"
  for supported in $_supported_locations
  do
    if [ "$_location" == "$supported" ]; then
      info "Azure location ${_location} is supported for Azure Arc"
      _supported="true"
      break   # break the for looop
    fi
  done
  if [ "$_supported" == "false" ]; then
    warning "Azure location ${_location} currently not supported for Azure Arc"
    exit 0
  fi
fi

# shellcheck disable=SC2086
while [ "$(ini_val $config_file c12:bootstrap.phase)" != "done" ]
do
    # shellcheck disable=SC2086
    case "$(ini_val $config_file c12:bootstrap.phase)" in
        "bootstrap-config-generated")
            test_config
            ini_val "$config_file" c12:bootstrap.phase "bootstrap-config-tested"
            ;;
        "bootstrap-config-tested")
            terraform_storage_account
            ini_val "$config_file" c12:bootstrap.phase "storage-account-created"
            ;;
        "storage-account-created")
            aad_groups_create
            ini_val "$config_file" c12:bootstrap.phase "aad-groups-created"
            ;;
        "aad-groups-created")
            terraform_network
            ini_val "$config_file" c12:bootstrap.phase "network-created"
            ;;
        "network-created")
            terraform_aks
            ini_val "$config_file" c12:bootstrap.phase "aks-created"
            ;;
        "aks-created")
            github_repos_create
            ini_val "$config_file" c12:bootstrap.phase "github-created"
            ;;
        "github-created")
            provision_ci_docker_image
            ini_val "$config_file" c12:bootstrap.phase "ci-images-provisioned"
            ;;
        "ci-images-provisioned")
            github_teams_create
            ini_val "$config_file" c12:bootstrap.phase "github-teams-created"
            ;;
        "github-teams-created")
            aad_credentials_for_pipelines_create
            ini_val "$config_file" c12:bootstrap.phase "aad-credentials-for-pipelines-created"
            ;;
        "aad-credentials-for-pipelines-created")
            adopt_cluster
            ini_val "$config_file" c12:bootstrap.phase "cluster-adopted"
            ;;
        "cluster-adopted")
            hydrate_repos
            ini_val "$config_file" c12:bootstrap.phase "github-repos-hydrated"
            ;;
        "github-repos-hydrated")
            ini_val "$config_file" c12:bootstrap.phase "done"
            ;;
        *)
            error "Unknown C12 state - exiting - have you ran './bootstrap.sh --generate-config-example'?"
            exit 3
    esac
done
