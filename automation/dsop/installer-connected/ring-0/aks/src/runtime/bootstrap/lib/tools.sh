#!/usr/bin/env bash

## Tools / Functions that are used in multiple different scripts.

# Terraform Init - intialise a tf template + Azure Blob storage
# call with
function terraform_init() {

    if [[ $# -ne 3 ]];
    then
        error "terraform_init expects 3 arguments $# received"
        return 1
    fi

    local _storage_account_name
    local _container_name
    local _container_rg

    _storage_account_name="$1"
    _container_name="$2"
    _container_rg="$3"

    terraform init \
        -backend-config "storage_account_name=$_storage_account_name" \
        -backend-config "container_name=$_container_name" \
        -backend-config "resource_group_name=$_container_rg"
}

# Polls for the latest run of a workflow and waits until it
# Arg1 github username
# Arg2 github personal access toem
# Arg3 github organization
# Arg4 github repository name
function wait_for_gitgub_workflow() {

    if [[ $# -ne 4 ]];
    then
        error "wait_for_gitgub_workflow expects 4 arguments $# received"
        return 1
    fi

    local _pat_username="$1"
    local _pat_password="$2"
    local _org="$3"
    local _repo="$4"

    # First get the what is the workflow id.
    # This works only with one workflow
    local workflow_count=0
    local workkflow_list_response=""

    while [ $workflow_count -le 0 ]
    do
        workkflow_list_response=$(curl -s -u "$_pat_username":"$_pat_password" https://api.github.com/repos/"$_org"/"$_repo"/actions/workflows)
        error_message=$(echo "$workkflow_list_response" | jq -r '.message' | tr -d "\n")
        
        if [[ "$error_message" == "null" ]]
        then
             workflow_count=$(echo "$workkflow_list_response" | jq -r '.total_count' | tr -d "\n")
             debug "Workflows in repo: $workflow_count"
             if [ "$workflow_count" -gt "1" ]
             then
                error "This script only supports repositories with one workflow file, please PR to improve"
                exit 44
             fi
             if [ "$workflow_count" -lt "1" ]
             then
                error "The repository $_org/$_repo does not have any workflow"
                exit 44
             fi


        elif [[ "$error_message" == "Not Found" ]]
        then
             error "Repository $_org/$_repo not found"             
             exit 33
        else
             error "Unknown error received from GH $error_message"
             debug "$workkflow_list_response"
             exit 32
        fi
    done

    workflow_id=$(echo "$workkflow_list_response" | jq -r '.workflows[].id' | tr -d "\n")
    workflow_name=$(echo "$workkflow_list_response" | jq -r '.workflows[].name' | tr -d "\n")
    info "Polling for the status of $workflow_name"
    conclusion="temp"
    while [[ "$conclusion" = "temp" ]]
    do
        result=$(curl -s -u "$_pat_username":"$_pat_password" https://api.github.com/repos/"$_org"/"$_repo"/actions/workflows/"$workflow_id"/runs | jq '.workflow_runs | sort_by(.created_at) | reverse | .[0] | { status: .status, conclusion: .conclusion }')        
        status=$(echo "$result" | jq -r '.status' | tr -d "\n")
        info "Workflow $workflow_name for repo $_repo is $status"
        if [[ "$status" == "completed" ]]
        then
            conclusion=$(echo "$result" | jq -r '.conclusion' | tr -d "\n")
        else
            sleep 10
        fi
    done
    info "Workflow $workflow_name for repo $_repo is $status with conclusion $conclusion" 
    echo "$conclusion"
}