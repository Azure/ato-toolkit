#!/usr/bin/env bash

TOOLS_PATH="/app"

function az_cli_sp_login(){
    echo "Login to azure with az cli"
    az login --service-principal --tenant "$ARM_TENANT_ID" --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET"
}

function get-application-list() {

    APP_LIST_JSON=$("${TOOLS_PATH}"/appsourceextractor -a "${GITHUB_WORKSPACE}")
    APP_LIST=$(echo "$APP_LIST_JSON" | tail -1 | jq -r '.[]')
    echo "$APP_LIST"
}

function get-application-list-json() {

    APP_LIST_JSON=$("${TOOLS_PATH}"/appsourceextractor -a "${GITHUB_WORKSPACE}")
    APP_LIST=$(echo "$APP_LIST_JSON" | tail -1 | jq -r '.')
    echo "$APP_LIST"
}
