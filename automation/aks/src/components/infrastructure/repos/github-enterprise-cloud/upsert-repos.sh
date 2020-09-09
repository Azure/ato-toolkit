#!/usr/bin/env bash
set -euxo pipefail
# This script creates / updates repos. The $_repos param should be *all* repos needed in the system, not just new ones needs.

# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../../../runtime/bootstrap/lib/tools.sh"

_storage_account_name="$1"
_container_name="$2"
_container_rg="$3"
_access_token="$4"
_org="$5"
_prefix="$6"
_applications="$7"
_timestamp="$(date "+%Y:%m:%d-%H:%M")"


pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 2

terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

terraform plan \
    -lock=true \
    -out "${_timestamp}.tfplan" \
    -var "access_token=$_access_token" \
    -var "org=$_org" \
    -var "access_token=$_access_token" \
    -var "prefix=$_prefix" \
    -var "applications=$_applications"

terraform apply "${_timestamp}.tfplan"
rm "${_timestamp}.tfplan"
popd || exit 2

