#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

function get_all_k8s_objects_by_kind() {
    
    if [[ $# -ne 1 ]];
    then
        error "input parameter not received"
        return 1
    fi

    local _kind
    _kind="$1"
    kubectl get "$_kind" -o json  | jq -r '.items[]'
}

function configure_storage_classes() {

    if [[ $# -ne 1 ]];
    then
        error "input parameter not received"
        return 1
    fi

    local _disk_encryption_set_id
    _disk_encryption_set_id="$1"
    
    all_storage_classes=$(get_all_k8s_objects_by_kind "storageclasses.storage.k8s.io")

    #Iterate it over the non encrypted storage classes so we create a duplicated version with encryption
    for storageclass in $(echo "$all_storage_classes" | jq -r '. | select(.provisioner == "kubernetes.io/azure-disk") | select(.parameters.diskEncryptionSetID == null)  | .metadata.name')
    do
        echo "Creating encrypted storage class based on $storageclass"
        echo "$all_storage_classes" | jq --arg name "$storageclass" --arg disk_encryption_set_id "$_disk_encryption_set_id" '. | select(.metadata.name == $name) | . * {"parameters" : {"diskEncryptionSetID": $disk_encryption_set_id}}  | . *{"metadata": {"name": ( $name + "-encrypted") }}' | kubectl apply -f -
    done

    #Delete all storage classes that are not encryptable 
    #Currently this is impossible in AKS since they get recreated automatically
    #delete happens, but it gets re-applyed by the add-on manager anytime.
    #for storageclass in $(echo "$all_storage_classes" | jq -r 'select(.parameters.diskEncryptionSetID == null) | .metadata.name')
    #do
    #     kubectl delete storageclasses.storage.k8s.io "$storageclass"
    #done
}