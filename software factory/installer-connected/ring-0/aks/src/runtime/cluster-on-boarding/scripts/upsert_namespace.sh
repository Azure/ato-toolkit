#!/usr/bin/env bash
# -*- coding: utf-8 -*-

# shellcheck source=src/runtime/bootstrap/lib/logging.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../.. && pwd)/bootstrap/lib/logging.sh"

# shellcheck source=src/runtime/cluster-on-boarding/scripts/helpers.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/helpers.sh"

# Creates or updates a kubernetes namespace
function upsert_namespace() {

	if [ -z "$1" ] 
	then
		error "Missing input parameters"
		exit 1
	fi
	
	info "creating namespace $1"
	kubectl create namespace "$1" --dry-run=client -o yaml  | kubectl apply -f -
}