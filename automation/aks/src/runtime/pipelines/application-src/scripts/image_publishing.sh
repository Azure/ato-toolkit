#!/usr/bin/env bash
# -*- coding: utf-8 -*-

lowerize() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

function image_publishing () {
    # Test if exactly four arguments are passed into the function
    if [[ $# -ne 2 ]];
    then
        echo "Error: Expecting 2 arguments for this function"
        exit 1
    fi
    # Validate existence of environment variables
    if [ -z "$IMAGE_REPOSITORY_USERNAME" ] 
    then
    echo "Error: IMAGE_REPOSITORY_USERNAME is not set"
    exit 1
    fi
    
    if [ -z "$IMAGE_REPOSITORY_PASSWORD" ] 
    then
    echo "Error: IMAGE_REPOSITORY_PASSWORD is not set"
    exit 1
    fi
    # Create variables for arguments
    ACR_IMAGE_URL="$1"
    APP_IMAGE_NAME="$2"
    # Log in to DEV ACR with service principal credentials
    echo -n "$IMAGE_REPOSITORY_PASSWORD" | docker login "$ACR_IMAGE_URL" --username "$IMAGE_REPOSITORY_USERNAME" --password-stdin
    docker push "$ACR_IMAGE_URL"/"$APP_IMAGE_NAME"
    docker logout "$ACR_IMAGE_URL"
}
