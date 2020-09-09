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

pushd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 2

terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

terraform destroy \
    -auto-approve \
    -var "subscription_id=$_subscription_id" \
    -var "prefix=$_prefix" \
    -var "applications=$_applications"

rm -rf .terraform
popd || exit 2