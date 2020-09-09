#!/usr/bin/env bash
# shellcheck source=src/runtime/bootstrap/lib/tools.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib/tools.sh"


# Installs all the required software on jumphost
function install_dependencies() {

	curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
	# required az cli extentions for Azure Arc
	az extension add --name connectedk8s
	az extension add --name k8sconfiguration

	# latest Kubernetes
	sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg2
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
	sudo apt-get update
	sudo apt-get install -y kubectl

	# instal latest Helm 3
	curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

}

# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function terraform_network(){

    local _timestamp
    local _location
    local _subscription
    local _prefix
    local _storage_account_name
    local _container_name
    local _container_rg
    local _vnet_id
    local _ssh_key_location
    local _jumphost_user
    local _jumphost_ip

    _timestamp=$(date "+%Y:%m:%d-%H:%M")

    info "Creating Networks"

    pushd ../../components/infrastructure/azure/network/ || exit 2

    pwd

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)

    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)

    terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

    terraform plan \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "location=$_location" \
        -var "subscription_id=$_subscription" \
        -var "prefix=$_prefix"

    terraform apply "${_timestamp}.tfplan"

    _vnet_id=$(terraform output vnet_id)
    _ssh_key_location="$(pwd)/$(terraform output ssh_key_location)"
    _jumphost_user=$(terraform output jumphost_user)
    _jumphost_ip=$(terraform output jumphost_ip)


    ini_val "$config_file" c12:generated.vnet-id "$_vnet_id"
    ini_val "$config_file" c12:generated.jumphost_ssh_key_location "$_ssh_key_location"
    ini_val "$config_file" c12:generated.jumphost_user "$_jumphost_user"
    ini_val "$config_file" c12:generated.jumphost_ip "$_jumphost_ip"


    ssh -oStrictHostKeyChecking=no "$_jumphost_user"@"$_jumphost_ip" -i "$_ssh_key_location" "cat /etc/hostname && ifconfig"
    ssh -oStrictHostKeyChecking=no "$_jumphost_user"@"$_jumphost_ip" -i "$_ssh_key_location" "sudo apt-get -y update && sudo apt-get install -y tinyproxy"
	# shellcheck disable=SC2154
	ssh -oStrictHostKeyChecking=no "$_jumphost_user"@"$_jumphost_ip" -i "$_ssh_key_location" "$(typeset -f); install_dependencies"

    rm "$_timestamp.tfplan"

    popd || exit 2

    info "Created Networks"

}

# we know the config_file var is set from script that is sourcing this one
# shellcheck disable=SC2154
function destroy_network(){

    local _timestamp
    local _location
    local _subscription
    local _prefix

     _timestamp=$(date "+%Y:%m:%d-%H:%M")

    info "Destroying Networks"

    pushd ../../components/infrastructure/azure/network/ || exit 2

    pwd

    _location=$(ini_val "$config_file" azure.location)
    _subscription=$(ini_val "$config_file" azure.subscription)
    _prefix=$(ini_val "$config_file" c12.prefix)

    _storage_account_name=$(ini_val "$config_file" terraform:generated.storage-account-name)
    _container_name=$(ini_val "$config_file" terraform:generated.container-name)
    _container_rg=$(ini_val "$config_file" terraform:generated.container-rg)

    terraform_init "$_storage_account_name" "$_container_name" "$_container_rg"

    terraform plan -destroy \
        -lock=true \
        -out "${_timestamp}.tfplan" \
        -var "location=$_location" \
        -var "subscription_id=$_subscription"  \
        -var "prefix=$_prefix"

    terraform apply "${_timestamp}.tfplan"

    rm "$_timestamp.tfplan"
    rm -rf .terraform

    popd || exit 2

    info "Destroyed Networks"

}