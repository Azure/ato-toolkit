#!/usr/bin/env bash
set -euo pipefail
# This script creates / updates repos. The $_repos param should be *all* repos needed in the system, not just new ones needs.

# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../../runtime/bootstrap/lib/tools.sh"

_storage_account_name="$1"
_container_name="$2"
_container_rg="$3"
_subscription_id="$4"
_prefix="$5"
_applications="$6"
_ini_file=${7:-}
_timestamp="$(date "+%Y:%m:%d-%H:%M")"

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 2

terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

terraform plan \
    -lock=true \
    -out "${_timestamp}.tfplan" \
    -var "subscription_id=$_subscription_id" \
    -var "prefix=$_prefix" \
    -var "applications=$_applications"

terraform apply "${_timestamp}.tfplan"

if [ -n "${_ini_file:-}" ];
then
    _break_glass="$(terraform output break_glass_id)"
    _read_only="$(terraform output read_only_id)"
    _sre="$(terraform output sre_id)"

    ini_val "$_ini_file" c12:generated.break-glass_group_id "$_break_glass"
    ini_val "$_ini_file" c12:generated.read-only_group_id "$_read_only"
    ini_val "$_ini_file" c12:generated.sre_group_id "$_sre"
fi

rm "${_timestamp}.tfplan"
popd || exit 2