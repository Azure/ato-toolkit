#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# Builds images for each Dockerfile found recursively in the given directory.
# Resolves image dependencies for images in the same organization.
# Tags images based on the directory structure and git branch names.
#
# source ./image_build.sh
# Usage:image_build [Dockerfile|directory] [...]

# Normalizes according to docker hub organization/image naming conventions:
normalize() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9._-]//g'
}

lowerize() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Builds an image for each git branch of the given Dockerfile directory:
build_versions() {
  image="$1"
  # unset image var
  shift 1
  git_tag="$(git log -1 --format=%H)"
  docker build -t "$image:$git_tag" "$@" .
}


# Builds an image for each git branch of the given Dockerfile directory:
build() {
  cwd="$PWD"
  file="$(basename "$1")"
  dir="$(dirname "$1")"
  cd "$dir" || return 1
  organization="$ACR_IMAGE_URL"
  if [ -z "$organization" ]; then
    # Use the parent folder for the organization/user name:
    organization="$(cd ../.. && normalize "$(basename "$PWD")")"
  fi
  # Use the REPO_GITHUB env for the image name:
  image="$organization/$(lowerize "$REPO_GITHUB")"
  # Check if the image depends on another image of the same organization:
  echo -n "$IMAGE_REPOSITORY_PASSWORD" | docker login "$ACR_IMAGE_URL" --username "$IMAGE_REPOSITORY_USERNAME" --password-stdin
  # docker pull "$image"
  build_versions "$image" -f "$file"
  status=$?
  cd "$cwd" || return 1
  return $status
}

# Builds and tags images for each Dockerfile in the arguments list:
build_images() {
  for file; do
    # Shift the arguments list to remove the current Dockerfile:
    shift
    # Basic check if the file is a valid Dockerfile:
    if ! grep '^FROM ' "$file"; then
      echo "Invalid Dockerfile: $file" >&2
      continue
    else 
      build "$file"
    fi
  done
}

NEWLINE='
'
# finds Dockerfiles and starts the builds:
find_dockerfiles() {
  dockerfiles_list=
  for arg; do
    if [ -d "$arg" ]; then
      # Search for Dockerfiles and add them to the list:
      dockerfiles_list="$dockerfiles_list$NEWLINE$(find "$arg" -name Dockerfile)"
    else
      dockerfiles_list="$dockerfiles_list$NEWLINE$arg"
    fi
  done
  # Set the list as arguments, splitting only at newlines:
  IFS="$NEWLINE";
  # shellcheck disable=SC2086
  set -- $dockerfiles_list;
  unset IFS
  build_images "$@"
}

function image_build () {
# Test if exactly 4 arguments are passed into the function
if [ -z "$ACR_IMAGE_URL" ] 
then
  echo "Error: ACR_IMAGE_URL is not set"
  exit 1
fi
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
  # finds Dockerfiles and starts the builds:
  find_dockerfiles "${@:-.}"
}

# Usage:image_build [Dockerfile|directory] [...]
