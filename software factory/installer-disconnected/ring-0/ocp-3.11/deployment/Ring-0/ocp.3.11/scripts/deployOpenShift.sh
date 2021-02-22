echo $(date) " - Starting Script"

set -e

export SUDOUSER=${SUDOUSER}
export PASSWORD=${PASSWORD}
export MASTER=${MASTER}
export MASTERPUBLICIPHOSTNAME=${MASTERPUBLICIPHOSTNAME}
export MASTERPUBLICIPADDRESS=${MASTERPUBLICIPADDRESS}
export INFRA=${INFRA}
export NODE=${NODE}
export NODECOUNT=${NODECOUNT}
export INFRACOUNT=${INFRACOUNT}
export MASTERCOUNT=${MASTERCOUNT}
export ROUTING=${ROUTING}
export REGISTRYSA=${REGISTRYSA}
export ACCOUNTKEY=${ACCOUNTKEY}
export METRICS=${METRICS}
export LOGGING=${LOGGING}
export TENANTID=${TENANTID}
export SUBSCRIPTIONID=${SUBSCRIPTIONID}
export AADCLIENTID=${AADCLIENTID}
export AADCLIENTSECRET=${AADCLIENTSECRET}
export RESOURCEGROUP=${RESOURCEGROUP}
export LOCATION=${LOCATION}
export AZURE=${AZURE}
export STORAGEKIND=${STORAGEKIND}
export ENABLECNS=${ENABLECNS}
export CNS=${CNS}
export CNSCOUNT=${CNSCOUNT}
export VNETNAME=${VNETNAME}
export NODENSG=${NODENSG}
export NODEAVAILIBILITYSET=${NODEAVAILIBILITYSET}
export MASTERCLUSTERTYPE=${MASTERCLUSTERTYPE}
export PRIVATEIP=${PRIVATEIP}
export PRIVATEDNS=${PRIVATEDNS}
export INFRAPIPNAME=${INFRAPIPNAME}
export CUSTOMROUTINGCERTTYPE=${CUSTOMROUTINGCERTTYPE}
export CUSTOMMASTERCERTTYPE=${CUSTOMMASTERCERTTYPE}
export MINORVERSION=${MINORVERSION}
export REPOSERVER=${REPOSERVER}
export REGISTRYSERVER=${REGISTRYSERVER}
export DEPLOYMENTTYPE=${DEPLOYMENTTYPE}
export DOCKERREGISTRYREALM=${DOCKERREGISTRYREALM} #
# export CLOUDNAME=${CLOUDNAME} # for AAD
export BASTION=$(hostname)

# Set CNS to default storage type.  Will be overridden later if Azure is true
export CNS_DEFAULT_STORAGE=true

# Setting DOMAIN variable
export DOMAIN=`domainname -d`

# Determine if Commercial Azure or Azure Government
# CLOUD=$( curl -H Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-04-02&format=text" | cut -c 1-2 )
export CLOUD=${CLOUD^^}
# export CLOUDNAME="AzureUSGovernmentCloud"
# export CLOUDNAME="AzurePublicCloud"

export MASTERLOOP=$((MASTERCOUNT - 1))
export INFRALOOP=$((INFRACOUNT - 1))
export NODELOOP=$((NODECOUNT - 1))

echo $(date) " - Configuring SSH ControlPath to use shorter path name"

sed -i -e "s/^# control_path = %(directory)s\/%%h-%%r/control_path = %(directory)s\/%%h-%%r/" /etc/ansible/ansible.cfg
sed -i -e "s/^#host_key_checking = False/host_key_checking = False/" /etc/ansible/ansible.cfg
sed -i -e "s/^#pty=False/pty=False/" /etc/ansible/ansible.cfg
sed -i -e "s/^#stdout_callback = skippy/stdout_callback = skippy/" /etc/ansible/ansible.cfg
sed -i -e "s/^#pipelining = False/pipelining = True/" /etc/ansible/ansible.cfg

# echo $(date) " - Modifying sudoers"
sed -i -e "s/Defaults    requiretty/# Defaults    requiretty/" /etc/sudoers
sed -i -e '/Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"/aDefaults    env_keep += "PATH"' /etc/sudoers

# Setting the default openshift_cloudprovider_kind if Azure enabled
if [[ ${AZURE} == "true" ]]
then
    CLOUDKIND="openshift_cloudprovider_kind=azure
openshift_cloudprovider_azure_client_id=${AADCLIENTID}
openshift_cloudprovider_azure_client_secret=${AADCLIENTSECRET}
openshift_cloudprovider_azure_tenant_id=${TENANTID}
openshift_cloudprovider_azure_subscription_id=${SUBSCRIPTIONID}
openshift_cloudprovider_azure_cloud=${CLOUDNAME}
openshift_cloudprovider_azure_vnet_name=${VNETNAME}
openshift_cloudprovider_azure_security_group_name=${NODENSG}
openshift_cloudprovider_azure_availability_set_name=${NODEAVAILIBILITYSET}
openshift_cloudprovider_azure_resource_group=${RESOURCEGROUP}
openshift_cloudprovider_azure_location=${LOCATION}"
	CNS_DEFAULT_STORAGE=false
	if [[ ${STORAGEKIND} == "managed" ]]
	then
		SCKIND="openshift_storageclass_parameters={'kind': 'managed', 'storageaccounttype': 'Premium_LRS'}"
	else
		SCKIND="openshift_storageclass_parameters={'kind': 'shared', 'storageaccounttype': 'Premium_LRS'}"
	fi
fi

# Cloning Ansible playbook repository

echo $(date) " - Cloning Ansible playbook repository"

if [[ ${DEPLOYMENTTYPE} == 3 ]]
then
    #Connected use this:
    ((cd /home/${SUDOUSER} && git clone https://github.com/Microsoft/openshift-container-platform-playbooks.git) || (cd /home/${SUDOUSER}/openshift-container-platform-playbooks && git pull))
else
    #Disconnected use this:
    cd /home/${SUDOUSER} && wget -r -np ${REPOSERVER}/ocpp/
    [ -d /home/${SUDOUSER}/openshift-container-platform-playbooks ] && rm -rf /home/${SUDOUSER}/openshift-container-platform-playbooks
    mv /home/${SUDOUSER}/${REPOSERVER}/ocpp /home/${SUDOUSER}/openshift-container-platform-playbooks
    [ -d /home/${SUDOUSER}/${REPOSERVER} ] && rm -rf /home/${SUDOUSER}/${REPOSERVER}
    cd /home/${SUDOUSER}/openshift-container-platform-playbooks
fi

if [ -d /home/${SUDOUSER}/openshift-container-platform-playbooks ]
then
    echo " - Retrieved playbooks successfully"
else
    echo " - Retrieval of playbooks failed"
    exit 7
fi

# Configure custom routing certificate
echo $(date) " - Create variable for routing certificate based on certificate type"
if [[ ${CUSTOMROUTINGCERTTYPE} == "custom" ]]
then
	ROUTINGCERTIFICATE="openshift_hosted_router_certificate={\"cafile\": \"/tmp/routingca.pem\", \"certfile\": \"/tmp/routingcert.pem\", \"keyfile\": \"/tmp/routingkey.pem\"}"
else
	ROUTINGCERTIFICATE=""
fi


# Configure master cluster address information based on Cluster type (private or public)
echo $(date) " - Create variable for master cluster address based on cluster type"
if [[ ${MASTERCLUSTERTYPE} == "private" ]]
then
    MASTERCLUSTERHOSTNAME=${PRIVATEDNS}
	MASTERCLUSTERADDRESS="openshift_master_cluster_hostname=${MASTER}-001v
openshift_master_cluster_public_hostname=${PRIVATEDNS}
openshift_master_cluster_public_vip=${PRIVATEIP}"
else
    MASTERCLUSTERHOSTNAME=${MASTERPUBLICIPHOSTNAME}
	MASTERCLUSTERADDRESS="openshift_master_cluster_hostname=${MASTERPUBLICIPHOSTNAME}
openshift_master_cluster_public_hostname=${MASTERPUBLICIPHOSTNAME}
openshift_master_cluster_public_vip=${MASTERPUBLICIPADDRESS}"
fi

# Configure custom master API certificate
echo $(date) " - Create variable for master api certificate based on certificate type"
if [[ ${CUSTOMMASTERCERTTYPE} == "custom" ]]
then
	MASTERCERTIFICATE="openshift_master_overwrite_named_certificates=true
openshift_master_named_certificates=[{\"names\": [\"${MASTERCLUSTERHOSTNAME}\"], \"cafile\": \"/tmp/masterca.pem\", \"certfile\": \"/tmp/mastercert.pem\", \"keyfile\": \"/tmp/masterkey.pem\"}]"
else
	MASTERCERTIFICATE=""
fi

# Create Master nodes grouping
echo $(date) " - Creating Master nodes grouping"
MASTERLIST="00${MASTERCOUNT}"
for c in $(seq -f "%03g" 1 ${MASTERCOUNT})
do
    mastergroup="$mastergroup
${MASTER}-${c}v openshift_node_group_name='node-config-master'"
done

# Create Infra nodes grouping 
echo $(date) " - Creating Infra nodes grouping"
for c in $(seq -f "%03g" 1 ${INFRACOUNT})
do
    infragroup="$infragroup
${INFRA}-${c}v openshift_node_group_name='node-config-infra'"
done

# Create Nodes grouping
echo $(date) " - Creating Nodes grouping"
for c in $(seq -f "%03g" 1 ${NODECOUNT})
do
    nodegroup="$nodegroup
${NODE}-${c}v openshift_node_group_name='node-config-compute'"
done

# Create CNS nodes grouping if CNS is enabled
if [[ ${ENABLECNS} == "true" ]]
then
    echo $(date) " - Creating CNS nodes grouping"

    for c in $(seq -f "%03g" 1 ${CNSCOUNT})
    do
        cnsgroup="$cnsgroup
${CNS}-${c}v openshift_node_group_name='node-config-compute'"
    done
fi

# Setting the HA Mode if more than one master
if [ ${MASTERCOUNT} != 1 ]
then
	echo $(date) " - Enabling HA mode for masters"
    export HAMODE="openshift_master_cluster_method=native"
fi

# Create Temp Ansible Hosts File
echo $(date) " - Create Ansible Hosts file"

cat > /etc/ansible/hosts <<EOF
[tempnodes]
$mastergroup
$infragroup
$nodegroup
$cnsgroup
EOF

# Run a loop playbook to ensure DNS Hostname resolution is working prior to continuing with script
echo $(date) " - Running DNS Hostname resolution check"
runuser -l ${SUDOUSER} -c "ansible-playbook ~/openshift-container-platform-playbooks/check-dns-host-name-resolution.yaml"

# Create glusterfs configuration if CNS is enabled
if [[ ${ENABLECNS} == "true" ]]
then
    echo $(date) " - Creating glusterfs configuration"

	# Ensuring selinux is configured properly
    echo $(date) " - Setting selinux to allow gluster-fuse access"
    runuser -l ${SUDOUSER} -c "ansible all -o -f 30 -b -a 'sudo setsebool -P virt_sandbox_use_fusefs on'" || true
	runuser -l ${SUDOUSER} -c "ansible all -o -f 30 -b -a 'sudo setsebool -P virt_use_fusefs on'" || true

    for c in $(seq -f "%03g" 1 ${CNSCOUNT})
    do
        runuser ${SUDOUSER} -c "ssh-keyscan -H ${CNS}-${c}v >> ~/.ssh/known_hosts"
        drive=$(runuser ${SUDOUSER} -c "ssh ${CNS}-${c}v 'sudo /usr/sbin/fdisk -l'" | awk '$1 == "Disk" && $2 ~ /^\// && ! /mapper/ {if (drive) print drive; drive = $2; sub(":", "", drive);} drive && /^\// {drive = ""} END {if (drive) print drive;}')
        drive1=$(echo $drive | cut -d ' ' -f 1)
        drive2=$(echo $drive | cut -d ' ' -f 2)
        drive3=$(echo $drive | cut -d ' ' -f 3)
        cnsglusterinfo="$cnsglusterinfo
${CNS}-${c}v glusterfs_devices='[ \"${drive1}\", \"${drive2}\", \"${drive3}\" ]'"
    done

    HOSTEDREGISTRYVALS="openshift_hosted_registry_storage_kind=glusterfs
openshift_hosted_registry_storage_volume_size=20Gi
openshift_hosted_registry_selector='node-role.kubernetes.io/infra=true'"

else

    HOSTEDREGISTRYVALS="openshift_hosted_registry_storage_kind=object
openshift_hosted_registry_storage_provider=azure_blob
openshift_hosted_registry_storage_azure_blob_accountname=${REGISTRYSA}
openshift_hosted_registry_storage_azure_blob_accountkey=${ACCOUNTKEY}
openshift_hosted_registry_storage_azure_blob_container=registry
openshift_hosted_registry_storage_azure_blob_realm=$DOCKERREGISTRYREALM"

fi

# Create Ansible Hosts File
echo $(date) " - Create Ansible Hosts file"

cat > /etc/ansible/hosts <<EOF
# Create an OSEv3 group that contains the masters and nodes groups
[OSEv3:children]
masters
nodes
etcd
master0
glusterfs
glusterfs_registry
new_nodes

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
ansible_ssh_user=${SUDOUSER}
ansible_become=yes
openshift_install_examples=true
deployment_type=openshift-enterprise
openshift_release=v3.11
openshift_image_tag=v3.11.${MINORVERSION}
openshift_pkg_version=-3.11.${MINORVERSION}
docker_udev_workaround=True
openshift_use_dnsmasq=true
openshift_master_default_subdomain=${ROUTING}
openshift_override_hostname_check=true
osm_use_cockpit=true
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_master_api_port=443
openshift_master_console_port=443
osm_default_node_selector='node-role.kubernetes.io/compute=true'
openshift_disable_check=memory_availability,docker_image_availability
$CLOUDKIND
$SCKIND
$CUSTOMCSS
$ROUTINGCERTIFICATE
$MASTERCERTIFICATE
$PROXY

# Workaround for docker image failure
# https://access.redhat.com/solutions/3480921
oreg_url=${REGISTRYSERVER}/openshift3/ose-\${component}:\${version}
openshift_examples_modify_imagestreams=true

# default selectors for router and registry services
openshift_router_selector='node-role.kubernetes.io/infra=true'
openshift_registry_selector='node-role.kubernetes.io/infra=true'

# Configure registry not to use Azure blob storage
openshift_hosted_registry_replicas=1
$HOSTEDREGISTRYVALS

# Deploy Service Catalog
openshift_enable_service_catalog=false

# Type of clustering being used by OCP
$HAMODE

# Addresses for connecting to the OpenShift master nodes
$MASTERCLUSTERADDRESS

# Enable HTPasswdPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

# Specify CNS images
openshift_storage_glusterfs_image=${REGISTRYSERVER}/rhgs3/rhgs-server-rhel7:v3.11
openshift_storage_glusterfs_block_image=${REGISTRYSERVER}/rhgs3/rhgs-gluster-block-prov-rhel7:v3.11
openshift_storage_glusterfs_s3_image=${REGISTRYSERVER}/rhgs3/rhgs-s3-server-rhel7:v3.11
openshift_storage_glusterfs_heketi_image=${REGISTRYSERVER}/rhgs3/rhgs-volmanager-rhel7:v3.11

# Setup metrics
openshift_metrics_install_metrics=$METRICS
openshift_metrics_start_cluster=$METRICS
openshift_metrics_hawkular_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_metrics_cassandra_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_metrics_heapster_nodeselector={"node-role.kubernetes.io/infra":"true"}

# Setup logging
openshift_logging_install_logging=$LOGGING
openshift_logging_fluentd_nodeselector={"logging":"true"}
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_kibana_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_curator_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_master_public_url=https://${MASTERCLUSTERHOSTNAME}

# host group for masters
[masters]
${MASTER}-[001:${MASTERLIST}]v

# host group for etcd
[etcd]
${MASTER}-[001:${MASTERLIST}]v

[master0]
${MASTER}-001v

# Only populated when CNS is enabled
[glusterfs]
$cnsglusterinfo

[glusterfs_registry]
$cnsglusterinfo

# host group for nodes
[nodes]
$mastergroup
$infragroup
$nodegroup
$cnsgroup

# host group for adding new nodes
[new_nodes]
EOF

# Update WALinuxAgent
echo $(date) " - Updating WALinuxAgent on all cluster nodes"
runuser ${SUDOUSER} -c "ansible all -f 30 -b -m yum -a 'name=WALinuxAgent state=latest'"

# Setup NetworkManager to manage eth0
echo $(date) " - Running NetworkManager playbook"
runuser -l ${SUDOUSER} -c "ansible-playbook -f 30 /usr/share/ansible/openshift-ansible/playbooks/openshift-node/network_manager.yml"

# Configure DNS so it always has the domain name
echo $(date) " - Adding $DOMAIN to search for resolv.conf"
runuser ${SUDOUSER} -c "ansible all -o -f 30 -b -m lineinfile -a 'dest=/etc/sysconfig/network-scripts/ifcfg-eth0 line=\"DOMAIN=$DOMAIN\"'"

# Configure resolv.conf on all hosts through NetworkManager
echo $(date) " - Restarting NetworkManager"
runuser -l ${SUDOUSER} -c "ansible all -o -f 30 -b -m service -a \"name=NetworkManager state=restarted\""
echo $(date) " - NetworkManager configuration complete"

# Restarting things so everything is clean before continuing with installation
echo $(date) " - Rebooting cluster to complete installation"
runuser -l ${SUDOUSER} -c "ansible-playbook -f 30 ~/openshift-container-platform-playbooks/reboot-master.yaml"
runuser -l ${SUDOUSER} -c "ansible-playbook -f 30 ~/openshift-container-platform-playbooks/reboot-nodes.yaml"
sleep 20

# Run OpenShift Container Platform prerequisites playbook
echo $(date) " - Running Prerequisites via Ansible Playbook"
runuser -l ${SUDOUSER} -c "ansible-playbook -f 30 /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml"
echo $(date) " - Prerequisites check complete"

# Initiating installation of OpenShift Container Platform using Ansible Playbook
echo $(date) " - Installing OpenShift Container Platform via Ansible Playbook"
runuser -l ${SUDOUSER} -c "ansible-playbook -f 30 /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml"
if [ $? -eq 0 ]
then
    echo $(date) " - OpenShift Cluster installed successfully"
else
    echo $(date) " - OpenShift Cluster failed to install"
    exit 6
fi

# Install OpenShift Atomic Client
cd /root
mkdir .kube
runuser ${SUDOUSER} -c "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${SUDOUSER}@${MASTER}-001v:~/.kube/config /tmp/kube-config"
cp /tmp/kube-config /root/.kube/config
mkdir /home/${SUDOUSER}/.kube
cp /tmp/kube-config /home/${SUDOUSER}/.kube/config
chown --recursive ${SUDOUSER} /home/${SUDOUSER}/.kube
rm -f /tmp/kube-config
yum -y install atomic-openshift-clients

# Adding user to OpenShift authentication file
echo $(date) " - Adding OpenShift user"
runuser ${SUDOUSER} -c "ansible-playbook -f 30 ~/openshift-container-platform-playbooks/addocpuser.yaml"

# Assigning cluster admin rights to OpenShift user
echo $(date) " - Assigning cluster admin rights to user"
runuser ${SUDOUSER} -c "ansible-playbook -f 30 ~/openshift-container-platform-playbooks/assignclusteradminrights.yaml"

# Installing Service Catalog, Ansible Service Broker and Template Service Broker
if [[ ${AZURE} == "true" || ${ENABLECNS} == "true" ]]
then
    runuser -l ${SUDOUSER} -c "ansible-playbook -e openshift_enable_service_catalog=true -f 30 /usr/share/ansible/openshift-ansible/playbooks/openshift-service-catalog/config.yml"
fi

# Adding Open Sevice Broker for Azaure (requires service catalog)
# Disabling deployment of OSBA
if [[ ${AZURE} == "true" ]]
then
    oc new-project osba
    oc process -f https://raw.githubusercontent.com/Azure/open-service-broker-azure/master/contrib/openshift/osba-os-template.yaml  \
        -p ENVIRONMENT=AzurePublicCloud \
        -p AZURE_SUBSCRIPTION_ID=${SUBSCRIPTIONID} \
        -p AZURE_TENANT_ID=${TENANTID} \
        -p AZURE_CLIENT_ID=${AADCLIENTID} \
        -p AZURE_CLIENT_SECRET=${AADCLIENTSECRET} \
        | oc create -f -
fi

# Configure Metrics
if [[ ${METRICS} == "true" ]]
then
    sleep 30
    echo $(date) "- Deploying Metrics"
    if [[ ${AZURE} == "true" || ${ENABLECNS} == "true" ]]
    then
        runuser -l ${SUDOUSER} -c "ansible-playbook -e openshift_metrics_install_metrics=True -e openshift_metrics_cassandra_storage_type=dynamic -f 30 /usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml"
    else
        runuser -l ${SUDOUSER} -c "ansible-playbook -e openshift_metrics_install_metrics=True /usr/share/ansible/openshift-ansible/playbooks/openshift-metrics/config.yml"
    fi
    if [ $? -eq 0 ]
    then
        echo $(date) " - Metrics configuration completed successfully"
    else
        echo $(date) " - Metrics configuration failed"
        exit 11
    fi
fi

# Configure Logging

if [[ ${LOGGING} == "true" ]]
then
    sleep 60
    echo $(date) "- Deploying Logging"
    if [[ ${AZURE} == "true" || ${ENABLECNS} == "true" ]]
    then
        runuser -l ${SUDOUSER} -c "ansible-playbook -e openshift_logging_install_logging=True -e openshift_logging_es_pvc_dynamic=true -f 30 /usr/share/ansible/openshift-ansible/playbooks/openshift-logging/config.yml"
    else
        runuser -l ${SUDOUSER} -c "ansible-playbook -e openshift_logging_install_logging=True -f 30 /usr/share/ansible/openshift-ansible/playbooks/openshift-logging/config.yml"
    fi
    if [ $? -eq 0 ]
    then
        echo $(date) " - Logging configuration completed successfully"
    else
        echo $(date) " - Logging configuration failed"
        exit 12
    fi
fi

if [[ ${AZURE} == "true" ]]
then
    # Creating variables file for private master and Azure AD configuration playbook
    echo $(date) " - Creating variables file for future playbooks"
cat > /home/${SUDOUSER}/openshift-container-platform-playbooks/vars.yaml <<EOF
admin_user: $SUDOUSER
master_lb_private_dns: $PRIVATEDNS
domain: $DOMAIN
EOF

    # Configure cluster for private masters
    if [[ ${MASTERCLUSTERTYPE} == "private" ]]
    then
        echo $(date) " - Configure cluster for private masters"
        runuser -l ${SUDOUSER} -c "ansible-playbook -f 30 ~/openshift-container-platform-playbooks/activate-private-lb-fqdn.31x.yaml"
    fi
fi

# Delete yaml files
echo $(date) " - Deleting unecessary files"
rm -rf /home/${SUDOUSER}/openshift-container-platform-playbooks

# Delete pem files
echo $(date) " - Delete pem files"
rm -rf /tmp/*.pem

echo $(date) " - Sleep for 15 seconds"
sleep 15

echo $(date) " - Script complete"

# *.apps.beta-openshift.com == 10.3.101.200
# *.console.beta-openshift.com == 10.3.101.100


# address=/console.dev-openshift.com/10.3.104.100
# address=/apps.dev-openshift.com/10.3.104.200
