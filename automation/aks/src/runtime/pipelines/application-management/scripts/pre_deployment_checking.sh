#!/usr/bin/env bash
# -*- coding: utf-8 -*-

function lint() {
    echo "lint app.yaml files"
  if [ "$1" ] && [ "$2" ]
  then
    docker run --mount src="$(pwd)",target=/mount-dir,type=bind stelligent/config-lint "$1" "$2"
    return 0
  else
    echo "No args.."
    echo "The program can also read files from a separate YAML file, and can scan these types of files:"
    return 1
  fi
}
