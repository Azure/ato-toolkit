#!/usr/bin/env bash
# -*- coding: utf-8 -*-


# This function will copy a container from a source ACR to a destination ACR
function copy_container_acr () {

    # Test if exactly four arguments are passed into the function
    if [[ $# -ne 4 ]];
    then
        echo "Error: Expecting 4 arguments for this function"
        exit 1
    fi

    # Validate existence of environment variables
	if [ -z "$SP_APP_ID" ] 
	then
		echo "Error: SP_APP_ID is not set"
		exit 1
	fi

    	if [ -z "$SP_APP_PASSWORD" ] 
	then
		echo "Error: SP_APP_PASSWORD is not set"
		exit 1
	fi

    # Create variables for arguments
    ACR_SRC="$1"
    ACR_DEST="$2"
    ACR_IMAGE_NAME="$3"
    ACR_IMAGE_DIGEST="$4"

    # Log in to source ACR with service principal credentials
    echo -n "$SP_PASSWORD" | sudo docker login "$ACR_SRC" --username "$SP_APP_ID" --password-stdin

    # Pull the container from the source ACR referencing the image digest
    sudo docker pull "$ACR_SRC"/"$ACR_IMAGE_NAME"@"$ACR_IMAGE_DIGEST"

    sudo docker logout "$ACR_SRC"

    # Get the local image ID using the digest
    IMAGE_ID=$(sudo docker images --format "{{.ID}}" --filter=reference="$ACR_SRC"/"$ACR_IMAGE_NAME"@"$ACR_IMAGE_DIGEST")

    # Tag the pulled image with the destination registry
    sudo docker tag "$IMAGE_ID" "$ACR_DEST"/"$ACR_IMAGE_NAME"

    # Log in to the destination ACR with service principal credentials
    echo -n "$SP_PASSWORD" | sudo docker login "$ACR_DEST" --username "$SP_APP_ID" --password-stdin

    # Push the newly tagged image to the destination registry
    sudo docker push "$ACR_DEST"/"$ACR_IMAGE_NAME"

    sudo docker logout "$ACR_DEST"

    # Remove the local image (needs a force since there are two)
    sudo docker image rm "$IMAGE_ID" -f

}
