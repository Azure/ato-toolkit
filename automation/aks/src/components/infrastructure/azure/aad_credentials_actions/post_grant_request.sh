#!/usr/bin/env bash
set -euxo pipefail

  function post_grant_request () {
    _resource_id=$(az ad sp show --id "$1" --query "objectId" -o json | jq "." -r)
    echo  "{\"principalId\": \"$3\", \"resourceId\": \"$_resource_id\", \"appRoleId\": \'$2\"}"
    az rest --method POST --uri https://graph.microsoft.com/beta/servicePrincipals/"$3"/appRoleAssignedTo \
            --header Content-Type=application/json \
            --body "{\"principalId\": \"$3\", \"resourceId\": \"$_resource_id\", \"appRoleId\": \"$2\"}"
  }

sleep 30
if [ -n "${GITHUB_ACTIONS+set}" ]; then
  # When on CI Pipeline Logged in Service Principal is currently unable to exec `az ad app permission admin-consent`
  # This calls the the Azure REST API and grants the listed Roles.
  echo "[INFO] sleep 30secs... "
  sleep 30 
  _principal_id=${SP_ID}
  echo "[INFO] grant AAD roles"
  post_grant_request "00000002-0000-0000-c000-000000000000" "78c8a3c8-a07e-4b9e-af1b-b5ccab50a175" "$_principal_id"
  post_grant_request "00000002-0000-0000-c000-000000000000" "1cda74f2-2616-4834-b122-5cb1b07f8a59" "$_principal_id"
  echo "[INFO] grant Microsoft Graph roles"
  post_grant_request "00000003-0000-0000-c000-000000000000" "06b708a9-e830-4db3-a914-8e69da51d44f" "$_principal_id"
  post_grant_request "00000003-0000-0000-c000-000000000000" "19dbc75e-c2e2-444c-a770-ec69d8559fc7" "$_principal_id"
else
  # When on Bootstrap (User account) use simpler Grant permission admin-consent
  az ad app permission admin-consent --id "${SP_APP_ID}"
fi



