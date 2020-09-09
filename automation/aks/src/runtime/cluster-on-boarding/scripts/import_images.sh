#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"


# import_image uploads an image to ACR without pulling and pulling. ACR pulls the image directly
# Arg 1 the name of the ACR where the image will be pulled.
# Arg 2 the image name with tag version included, ie: memcached:1.3.45
# returns the imported image full qualified/expanded name in the imported repository
function import_image() {
    if [[ $# -ne 2 ]];
    then
        error "input parameter not received"
        return 1
    fi

    acr_name=$1
    image=$(strip_tag "$2")
    tag=$(get_image_tag "$2")
    image_fq_name=$(to_full_qualified_image_name "$image")
   
    info "Importing into ACR ${acr_name} image ${image_fq_name}:${tag}"
    az acr import --force -n "${acr_name}" --source "${image_fq_name}":"${tag}"
    login_server=$(az acr show -n "$acr_name" --query 'loginServer' -o tsv |  tr -d "\n")
    rewrite_full_qualified_image_name "$image_fq_name" "$login_server"
}

# Strips the tag number from an image
# Arg1 the image with tag included
function strip_tag() {
   if [ -z "$1" ]
    then
        error "input parameter not received"
        return 1
    fi

   echo "$1" | cut -d: -f1
   return 0
}

# Gets the tag from an image if the image does not contain a tag, returns latest
# Arg1 the image name
function get_image_tag() {
    if [ -z "$1" ]
    then
        error "input parameter not received"
        return 1
    fi

    tag=$(echo "$1" | cut -d: -f2)
    #does the image miss the tag
    if [ "$1" == "$tag" ]
    then
        tag="latest"
    fi

    echo "$tag"
    return 0
}

# Applies the same logic as docker pull to get the full image names. IE: memcached is translated to
# docker.io/library/memcached. See unit tests for more examples. 
# Arg1 the image name. 
function to_full_qualified_image_name() {

    if [ -z "$1" ]
    then
        error "input parameter not received"
        return 1
    fi
    image=$1 
    domain=$(echo "$image" | cut -d/ -f1)
    domain_has_dots=$(echo "$domain" | cut -d. -f1)

    #does the image contain an slash? 
    if [ "$domain" == "$image" ]
    then
        echo "docker.io/library/$1"
        return 0
    #does the first part of the image name, has a dot? 
    elif [ "$domain" == "$domain_has_dots" ]
    then
        echo "docker.io/$1"     
        return 0
    fi
    echo "$image"
    return 0
}

# Rewrites an image into a new repo
# Arg1 the full image name without tags ie: docker.io/library/memcached
# Arg2 the domain of the new repository
function rewrite_full_qualified_image_name() {

    if [ -z "$1" ] || [ -z "$2" ]
    then
        error "input parameter not received"
        return 1
    fi

    image="$1"
    new_repo="$2"
    echo "$new_repo/${image#*/}"
    return 0
}
