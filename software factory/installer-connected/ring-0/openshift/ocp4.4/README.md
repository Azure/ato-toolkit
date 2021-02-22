# Summary

This document outlines the procedure for installation of an OpenShift 4.x cluster.  Not a private Azure region using the 4.3 installer. As of this writing, OpenShift supports a limited number of regions which excludes some customers from using the installer to create their cluster.

This document works with openshift 4.3.x and 4.4.x

## Offline reference

For deployments that are disconnected please see the following documentation.

[Mirror the container registry](https://docs.openshift.com/container-platform/4.4/installing/install_config/installing-restricted-networks-preparations.html#installing-restricted-networks-preparations)

Deploy that mirrored registry to azure, must be able to dns lookup.

## Install Procedures

### Prerequisites

Linux operating system

The following applications must be available in your path

- Azure Command Line Interface [(az)](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- Json Query [(jq)](https://stedolan.github.io/jq/)
- YAML Query [(yq)](https://pypi.org/project/yq/)
  - must be version <3.0.0
- OpenShift Client [(oc)](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/oc/4.3/linux/)
- OpenShift Installer [(openshift-install)](https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.3.21/)
- Kubernetes Client [(kubectl)](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

Azure Government subscription

Admin access to an account in Azure Government with contributor role on the target subscription

The following resource types must be available in your region, check [azure available services by region](https://azure.microsoft.com/en-us/global-infrastructure/services/).

- Availability Set
- Managed Disk
- Public DNS Zone
- Managed Image
- Load Balancer
- Managed Identity
- Network Interface
- Network Security Group
- Private DNS Zone
- Public IP address
- Storage Account
- Virtual Machine

Service principal with contributor access to a created resource group.

Ability to log into azure with az cli from your host machine

### Creating Install Config

Create a directory to do the installation from

```shell
mkdir ~/openshift_install/
```

Copy all ARM templates into this directory, they can be found [here](https://github.com/openshift/installer/tree/master/upi/azure), or copied from below.

Create the following file named install-config.yaml with this template in that directory

```yaml
#~/openshift_install/install-config.yaml
apiVersion: v1
baseDomain: <YOUR_PUBLIC_DNS_ZONE>
compute:
- hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: <YOUR_CLUSTER_NAME>
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  azure:
    baseDomainResourceGroupName: <YOUR_DNS_ZONE_RG>
    region: <YOUR_AZURE_PULIC_REGSION>
publish: External
pullSecret: '<YOUR_PULL_SECRET>'
sshKey: |
 <YOUR_SSH_KEY>
```

Create or modify this file to ensure the right azure environment secrets get passed, ~/.azure/osServicePrincipal.json. All of these values are in plain text, they will be translated to base64 encoded secrets during the install.

This must be valid azure public information, it is not used for the install process just command validation. These are not the values of the subscription in Azure Government.
```json
{
  "subscriptionId":"<YOUR_AZURE_PUBLIC_SUBSCRIPTION_ID",
  "clientId":"<YOUR_AZURE_PUBLIC_CLIENT_ID>",
  "clientSecret":"<YOUR_AZURE_PUBLIC_CLIENT_SECRET>",
  "tenantId":"<YOUR_AZURE_PUBLIC_TENANT_ID>"
}
```

The other option is to use the openshift-installer create installer-config with the following instructions

- select your private key
- platform azure
- subscription id: valid public azure id
- tenant id: valid public azure tenant id
- client id: valid public azure client id
- client secret: valid public azure client secret
- region: eastus
- base domain: valid public dns (doesn't have to be real, just a resource)
- cluster name: <your cluster name, must be valid storage account name>
- pull secret: value from https://cloud.redhat.com/openshift

### Useful Functions

These two functions are used throughout this readme as helpers, please load them into your environment.

```bash
# A function to write a var name and value out to a file for re-loading later
function saveVar()
{
  varname=$1
  varValue=$2
  echo "${varname}=\"${varValue}\"" >> restore.sh
}
```

```bash
# A function to enable debugging of azure commands
function echoDo()
# $1: Description
# $2: Command
{
    redirect=""
    if [ "$LOGOUTPUT" == "yes" ]; then
      redirect="| tee -a ${LOGFILE}"
    fi
    echo "Task: $1" $redirect
    shift
    C=''
    for i in "$@"; do 
       i="${i//\\/\\\\}"
       C="$C \"${i//\"/\\\"}\""
    done
    echo $C
    eval $C $redirect
    res=$?
    echo "--->> Result Code $res" $redirect
    return $res
}
```

### Azure Configuration

The following set of commands will log your shell into azure, set environment variables, create openshift manifes, and configure openshift manifests.

```bash
# Log into azure government
az cloud list -o table
az cloud set -n <desired cloud name | AzureUSGovernment>
# If you can access a browser
az login
# else (this method won't work with azure accounts with 2-factor enabled)
read -sp "Azure password: " AZ_PASS && echo && az login -u <username> -p $AZ_PASS
# or you can use a service principal with contributor access to the subscription
read -sp "Azure password: " AZ_PASS && echo && az login --service-principal -u <app-url> -p $AZ_PASS --tenant <tenant>

# Set environment Vars
CLUSTER_NAME=$(yq -r .metadata.name install-config.yaml)
echo "enter a valid azure gov region"
read AZURE_REGION
export AZURE_REGION
SSH_KEY=$(yq -r .sshKey install-config.yaml | xargs)
BASE_DOMAIN=$(yq -r .baseDomain install-config.yaml)
BASE_DOMAIN_RESOURCE_GROUP=$(yq -r .platform.azure.baseDomainResourceGroupName install-config.yaml)

# Change region back to eastus so manifests will create
python3 -c '
import yaml;
path = "install-config.yaml";
data = yaml.full_load(open(path));
data["platform"]["azure"]["region"] = "eastus";
open(path, "w").write(yaml.dump(data, default_flow_style=False))'


python3 -c '
import yaml;
path = "install-config.yaml";
data = yaml.full_load(open(path));
data["compute"][0]["replicas"] = 0;
open(path, "w").write(yaml.dump(data, default_flow_style=False))'

openshift-install create manifests
rm -fv openshift/99_openshift-cluster-api_master-machines-*.yaml
rm -fv openshift/99_openshift-cluster-api_worker-machineset-*.yaml

# Change cloud provider configuration
sed -i 's/AzurePublicCloud/AzureUSGovernmentCloud/' manifests/cloud-provider-config.yaml
#change manifests/cloud-provider-config.yaml to valid azure MAG tenantID, subscription id, and location (plain text)
#change openshift/99_cloud-creds-secret.yaml to valid Azure MAG values.
#values must be base64 encoded

#Let the masters be schedulable
python3 -c '
import yaml;
path = "manifests/cluster-scheduler-02-config.yml";
data = yaml.full_load(open(path));
data["spec"]["mastersSchedulable"] = False;
open(path, "w").write(yaml.dump(data, default_flow_style=False))'

#Delete private / public dns settings
python3 -c '
import yaml;
path = "manifests/cluster-dns-02-config.yml";
data = yaml.full_load(open(path));
del data["spec"]["publicZone"];
del data["spec"]["privateZone"];
open(path, "w").write(yaml.dump(data, default_flow_style=False))'

INFRA_ID=$(yq -r '.status.infrastructureName' manifests/cluster-infrastructure-02-config.yml)
RESOURCE_GROUP=$(yq -r '.status.platformStatus.azure.resourceGroupName' manifests/cluster-infrastructure-02-config.yml)

openshift-install create ignition-configs

saveVar CLUSTER_NAME $CLUSTER_NAME
saveVar AZURE_REGION $AZURE_REGION
saveVar SSH_KEY "${SSH_KEY}"
saveVar BASE_DOMAIN $BASE_DOMAIN
saveVar BASE_DOMAIN_RESOURCE_GROUP $BASE_DOMAIN_RESOURCE_GROUP
```

If you close your shell during this install you can restore your variables by running the following command

```bash
# To restore shell varables run
source restore.sh
# Test value
echo $CLUSTER_NAME
```

#### Create Azure Resource Group and Cluster Prerequisites

The following section will

- create an azure resource group
- create an azure storage account
- create an azure identity
- upload the RHCOS image to your storage account
- create an azure public dns zone
- create an azure private dns zone

Create the following function for better logging and output

```bash
#Set log output and file location
LOGOUTPUT="yes"
LOGFILE="~/openshift_install/azure-install.log"
azout="-o none"
OCPRELEASE="4.4"


#Backup vars
saveVar LOGOUTPUT $LOGOUTPUT
saveVar LOGFILE $LOGFILE
saveVar azout "${azout}"
saveVar OCPRELEASE $OCPRELEASE
```

Create the mentioned resources

```bash
echoDo "Create Resource Group" az group create --name $RESOURCE_GROUP --location $AZURE_REGION ${azout}
echoDo "Create Identity" az identity create -g $RESOURCE_GROUP -n ${INFRA_ID}-identity ${azout}
echoDo "Create Storage Account" az storage account create -g $RESOURCE_GROUP --location $AZURE_REGION --name ${CLUSTER_NAME}sa --kind Storage --sku Standard_LRS ${azout}
ACCOUNT_KEY=$(az storage account keys list -g $RESOURCE_GROUP --account-name ${CLUSTER_NAME}sa --query "[0].value" -o tsv)
VHD_URL=$(curl -s https://raw.githubusercontent.com/openshift/installer/release-$OCPRELEASE/data/data/rhcos.json | jq -r .azure.url)
echoDo "Create vhd Storage Container" az storage container create --name vhd --account-name ${CLUSTER_NAME}sa ${azout}
echoDo "Create file Storage Container" az storage container create --name files --account-name ${CLUSTER_NAME}sa --public-access blob ${azout}
echoDo "Upload bootstrap.ign to file storage" az storage blob upload --account-name ${CLUSTER_NAME}sa --account-key $ACCOUNT_KEY -c "files" -f "bootstrap.ign" -n "bootstrap.ign" ${azout}
echoDo "Start VHD to image creation" az storage blob copy start --account-name ${CLUSTER_NAME}sa --account-key $ACCOUNT_KEY --destination-blob "rhcos.vhd" --destination-container vhd --source-uri "$VHD_URL"
PRINCIPAL_ID=$(az identity show -g $RESOURCE_GROUP -n ${INFRA_ID}-identity --query principalId --out tsv)
RESOURCE_GROUP_ID=$(az group show -g $RESOURCE_GROUP --query id --out tsv)
echoDo "Create Service Account" az role assignment create --assignee "$PRINCIPAL_ID" --role 'Contributor' --scope "$RESOURCE_GROUP_ID" ${azout}
echoDo "Create public DNS Zone" az network dns zone create -g $RESOURCE_GROUP -n ${CLUSTER_NAME}.${BASE_DOMAIN} ${azout}
nsServer0=$(az network dns zone show --resource-group $RESOURCE_GROUP --name ${CLUSTER_NAME}.${BASE_DOMAIN} --query "nameServers[0]" -o tsv)
nsServer1=$(az network dns zone show --resource-group $RESOURCE_GROUP --name ${CLUSTER_NAME}.${BASE_DOMAIN} --query "nameServers[1]" -o tsv)
echoDo "Create NS Record Sets" az network dns record-set ns create --name ${CLUSTER_NAME} --resource-group $BASE_DOMAIN_RESOURCE_GROUP --zone-name ${BASE_DOMAIN} ${azout}
echoDo "Create NS record" az network dns record-set ns add-record --nsdname $nsServer0 -n ${CLUSTER_NAME} -g $BASE_DOMAIN_RESOURCE_GROUP -z ${BASE_DOMAIN} ${azout}
echoDo "Create NS record" az network dns record-set ns add-record --nsdname $nsServer1 -n ${CLUSTER_NAME} -g $BASE_DOMAIN_RESOURCE_GROUP -z ${BASE_DOMAIN} ${azout}
echoDo "Create Private DNS zone" az network private-dns zone create -g $RESOURCE_GROUP -n ${CLUSTER_NAME}.${BASE_DOMAIN} ${azout}
status="unknown"
while [ "$status" != "success" ]
do
  status=$(az storage blob show --container-name vhd --name "rhcos.vhd" --account-name ${CLUSTER_NAME}sa --account-key $ACCOUNT_KEY -o tsv --query properties.copy.status)
  echo $status
done

#Backup vars
saveVar VHD_URL "${VHD_URL}"
saveVar ACCOUNT_KEY $ACCOUNT_KEY
saveVar PRINCIPAL_ID $PRINCIPAL_ID
saveVar RESOURCE_GROUP_ID $RESOURCE_GROUP_ID
saveVar nsServer0 $nsServer0
saveVar nsServer1 $nsServer1
```

### Deploy Cluster

The following section with create:

- A bootstrap node
- 3 Master nodes
- An Azure virtual network
- An Azure managed image

Run the following command set to create the mentioned resources

```bash
echoDo "Create VNET"  az deployment group create -g $RESOURCE_GROUP \
  --template-file "01_vnet.json" \
  --parameters baseName="$INFRA_ID" ${azout}
echoDo "Associate private-dns with virtual network" az network private-dns link vnet create -g $RESOURCE_GROUP -z ${CLUSTER_NAME}.${BASE_DOMAIN} -n ${INFRA_ID}-network-link -v "${INFRA_ID}-vnet" -e false ${azout}
VHD_BLOB_URL=$(az storage blob url --account-name ${CLUSTER_NAME}sa --account-key $ACCOUNT_KEY -c vhd -n "rhcos.vhd" -o tsv)
# looks like we need a short delay here
sleep 10
echoDo "Setup azure VHD storage" az deployment group create -g $RESOURCE_GROUP \
  --template-file "02_storage.json" \
  --parameters vhdBlobURL="$VHD_BLOB_URL" \
  --parameters baseName="$INFRA_ID" ${azout}
echoDo "Setup PrivateDNS records for infrastructure" az deployment group create -g $RESOURCE_GROUP \
  --template-file "03_infra.json" \
  --parameters privateDNSZoneName="${CLUSTER_NAME}.${BASE_DOMAIN}" \
  --parameters baseName="$INFRA_ID" ${azout}
PUBLIC_IP=$(az network public-ip list -g $RESOURCE_GROUP --query "[?name=='${INFRA_ID}-master-pip'] | [0].ipAddress" -o tsv)
echoDo "Add public A record for api end point" az network dns record-set a add-record -g $RESOURCE_GROUP -z ${CLUSTER_NAME}.${BASE_DOMAIN} -n api -a $PUBLIC_IP --ttl 60 ${azout}
BOOTSTRAP_URL=$(az storage blob url --account-name ${CLUSTER_NAME}sa --account-key $ACCOUNT_KEY -c "files" -n "bootstrap.ign" -o tsv)
BOOTSTRAP_IGNITION=$(jq -rcnM --arg v "2.2.0" --arg url $BOOTSTRAP_URL '{ignition:{version:$v,config:{replace:{source:$url}}}}' | base64 -w0)
echoDo "Create Bootstrap" az deployment group create -g $RESOURCE_GROUP \
  --template-file "04_bootstrap.json" \
  --parameters bootstrapIgnition="$BOOTSTRAP_IGNITION" \
  --parameters sshKeyData="$SSH_KEY" \
  --parameters baseName="$INFRA_ID" ${azout}
echoDo "Create masters" az deployment group create -g $RESOURCE_GROUP \
  --template-file "05_masters.json" \
  --parameters masterIgnition="$(base64 -w0 master.ign)" \
  --parameters sshKeyData="$SSH_KEY" \
  --parameters privateDNSZoneName="${CLUSTER_NAME}.${BASE_DOMAIN}" \
  --parameters baseName="$INFRA_ID" \
  --no-wait ${azout}

# Backup Variables
saveVar VHD_BLOB_URL "${VHD_BLOB_URL}"
saveVar PUBLIC_IP $PUBLIC_IP
saveVar BOOTSTRAP_URL $BOOTSTRAP_URL
saveVar BOOTSTRAP_IGNITION $BOOTSTRAP_IGNITION

openshift-install wait-for bootstrap-complete --log-level debug
```

## Post Cluster Startup

This section will

- Deploy 3 worker nodes
- Configure worker nodes
- Connect OC to new cluster
- Remove bootstrap server

```bash
# Connect OC to created cluster
export KUBECONFIG="$PWD/auth/kubeconfig"
oc get nodes
oc get clusteroperator
```

```bash
WORKERNODES=3
echoDo "Create Worker Nodes" az deployment group create -g $RESOURCE_GROUP \
  --template-file "06_workers.json" \
  --parameters workerIgnition="$(base64 -w0 worker.ign)" \
  --parameters sshKeyData="$SSH_KEY" \
  --parameters baseName="$INFRA_ID" \
  --parameters numberOfNodes="$WORKERNODES" \
  --no-wait ${azout}

# Remove bootstrap
echo Remove Bootstrap resources
echoDo "Remove SSH access to Bootstrap" az network nsg rule delete -g $RESOURCE_GROUP --nsg-name ${INFRA_ID}-controlplane-nsg --name bootstrap_ssh_in ${azout}
echoDo "Stop Bootstrap VM" az vm stop -g $RESOURCE_GROUP --name ${INFRA_ID}-bootstrap ${azout}
echoDo "Deallocated Bootstrap VM" az vm deallocate -g $RESOURCE_GROUP --name ${INFRA_ID}-bootstrap ${azout}
echoDo "Delete Bootstrap VM" az vm delete -g $RESOURCE_GROUP --name ${INFRA_ID}-bootstrap --yes ${azout}
echoDo "Delete Bootstrap OS Disk" az disk delete -g $RESOURCE_GROUP --name ${INFRA_ID}-bootstrap_OSDisk --no-wait --yes ${azout}
echoDo "Delete Bootstrap NIC" az network nic delete -g $RESOURCE_GROUP --name ${INFRA_ID}-bootstrap-nic --no-wait ${azout}
echoDo "Delete ignition file for RHCOS bootstrapping" az storage blob delete --account-key $ACCOUNT_KEY --account-name ${CLUSTER_NAME}sa --container-name files --name bootstrap.ign ${azout}
echoDo "Delete public IP for ssh access" az network public-ip delete -g $RESOURCE_GROUP --name ${INFRA_ID}-bootstrap-ssh-pip ${azout}
```

After a few mintutes run these commands to configure the worker nodes

```bash
# Get CSR ids of pending requests
oc get csr -A

# Approve CSR ids
oc get csr -ojson | jq -r '.items[] | select(.status == {} ) | .metadata.name' | xargs oc adm certificate approve

# Nodes should populate and become ready in a couple of minutes
watch oc get nodes
```

Disable the Image Registry operator

```bash
oc edit configs.imageregistry.operator.openshift.io/cluster
# change managedState: Managed --> Removed
```

Add DNS Records in public and private dns zone of the ip address assigned to the new load balancer.

*.apps --> ip address of new LB

Create the following file as azure-disk.yaml

```yaml
# azure-disk.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    description: azure disk
    storageclass.kubernetes.io/is-default-class: "true"
  name: azuredisk
parameters:
  kind: managed
  location: <your_region>
  skuName: <your_sku>
provisioner: kubernetes.io/azure-disk
reclaimPolicy: Delete
volumeBindingMode: Immediate
```

Apply the storage class

```bash
oc apply -f azure-disk.yaml
```

Wait for cluster install to complete and login to web gui
```bash
openshift-install44 wait-for install-complete
```

## Known Issues

- Image Registry doesn't work
- DNS Operator doesn't work
  - this is mitigated by adding the *.apps A record to the dns zones
- OCP cluster won't auto scale
  - To work around this you can re-run the workers arm template
- Cluster secrets operator doesn't work

## ARM Template Reference

These are the ARM templates mentioned throughout the document.

01_vnet.json

```json
{
  "$schema" : "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion" : "1.0.0.0",
  "parameters" : {
    "baseName" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Base name to be used in resource names (usually the cluster's Infra ID)"
      }
    }
  },
  "variables" : {
    "location" : "[resourceGroup().location]",
    "virtualNetworkName" : "[concat(parameters('baseName'), '-vnet')]",
    "addressPrefix" : "10.0.0.0/16",
    "masterSubnetName" : "[concat(parameters('baseName'), '-master-subnet')]",
    "masterSubnetPrefix" : "10.0.0.0/24",
    "nodeSubnetName" : "[concat(parameters('baseName'), '-worker-subnet')]",
    "nodeSubnetPrefix" : "10.0.1.0/24",
    "controlPlaneNsgName" : "[concat(parameters('baseName'), '-controlplane-nsg')]",
    "nodeNsgName" : "[concat(parameters('baseName'), '-node-nsg')]"
  },
  "resources" : [
    {
      "apiVersion" : "2018-12-01",
      "type" : "Microsoft.Network/virtualNetworks",
      "name" : "[variables('virtualNetworkName')]",
      "location" : "[variables('location')]",
      "dependsOn" : [
        "[concat('Microsoft.Network/networkSecurityGroups/', variables('controlPlaneNsgName'))]",
        "[concat('Microsoft.Network/networkSecurityGroups/', variables('nodeNsgName'))]"
      ],
      "properties" : {
        "addressSpace" : {
          "addressPrefixes" : [
            "[variables('addressPrefix')]"
          ]
        },
        "subnets" : [
          {
            "name" : "[variables('masterSubnetName')]",
            "properties" : {
              "addressPrefix" : "[variables('masterSubnetPrefix')]",
              "serviceEndpoints": [],
              "networkSecurityGroup" : {
                "id" : "[resourceId('Microsoft.Network/networkSecurityGroups', variables('controlPlaneNsgName'))]"
              }
            }
          },
          {
            "name" : "[variables('nodeSubnetName')]",
            "properties" : {
              "addressPrefix" : "[variables('nodeSubnetPrefix')]",
              "serviceEndpoints": [],
              "networkSecurityGroup" : {
                "id" : "[resourceId('Microsoft.Network/networkSecurityGroups', variables('nodeNsgName'))]"
              }
            }
          }
        ]
      }
    },
    {
      "type" : "Microsoft.Network/networkSecurityGroups",
      "name" : "[variables('controlPlaneNsgName')]",
      "apiVersion" : "2018-10-01",
      "location" : "[variables('location')]",
      "properties" : {
        "securityRules" : [
          {
            "name" : "apiserver_in",
            "properties" : {
              "protocol" : "Tcp",
              "sourcePortRange" : "*",
              "destinationPortRange" : "6443",
              "sourceAddressPrefix" : "*",
              "destinationAddressPrefix" : "*",
              "access" : "Allow",
              "priority" : 101,
              "direction" : "Inbound"
            }
          }
        ]
      }
    },
    {
      "type" : "Microsoft.Network/networkSecurityGroups",
      "name" : "[variables('nodeNsgName')]",
      "apiVersion" : "2018-10-01",
      "location" : "[variables('location')]",
      "properties" : {
        "securityRules" : [
          {
            "name" : "apiserver_in",
            "properties" : {
              "protocol" : "Tcp",
              "sourcePortRange" : "*",
              "destinationPortRange" : "6443",
              "sourceAddressPrefix" : "*",
              "destinationAddressPrefix" : "*",
              "access" : "Allow",
              "priority" : 101,
              "direction" : "Inbound"
            }
          }
        ]
      }
    }
  ]
}
```

02_storage.json

```json
{
  "$schema" : "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion" : "1.0.0.0",
  "parameters" : {
    "baseName" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Base name to be used in resource names (usually the cluster's Infra ID)"
      }
    },
    "vhdBlobURL" : {
      "type" : "string",
      "metadata" : {
        "description" : "URL pointing to the blob where the VHD to be used to create master and worker machines is located"
      }
    }
  },
  "variables" : {
    "location" : "[resourceGroup().location]",
    "imageName" : "[concat(parameters('baseName'), '-image')]"
  },
  "resources" : [
    {
      "apiVersion" : "2018-06-01",
      "type": "Microsoft.Compute/images",
      "name": "[variables('imageName')]",
      "location" : "[variables('location')]",
      "properties": {
        "storageProfile": {
          "osDisk": {
            "osType": "Linux",
            "osState": "Generalized",
            "blobUri": "[parameters('vhdBlobURL')]",
            "storageAccountType": "Standard_LRS"
          }
        }
      }
    }
  ]
}
```

03_infra.json

```json
{
  "$schema" : "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion" : "1.0.0.0",
  "parameters" : {
    "baseName" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Base name to be used in resource names (usually the cluster's Infra ID)"
      }
    },
    "privateDNSZoneName" : {
      "type" : "string",
      "metadata" : {
        "description" : "Name of the private DNS zone"
      }
    }
  },
  "variables" : {
    "location" : "[resourceGroup().location]",
    "virtualNetworkName" : "[concat(parameters('baseName'), '-vnet')]",
    "virtualNetworkID" : "[resourceId('Microsoft.Network/virtualNetworks', variables('virtualNetworkName'))]",
    "masterSubnetName" : "[concat(parameters('baseName'), '-master-subnet')]",
    "masterSubnetRef" : "[concat(variables('virtualNetworkID'), '/subnets/', variables('masterSubnetName'))]",
    "masterPublicIpAddressName" : "[concat(parameters('baseName'), '-master-pip')]",
    "masterPublicIpAddressID" : "[resourceId('Microsoft.Network/publicIPAddresses', variables('masterPublicIpAddressName'))]",
    "masterLoadBalancerName" : "[concat(parameters('baseName'), '-public-lb')]",
    "masterLoadBalancerID" : "[resourceId('Microsoft.Network/loadBalancers', variables('masterLoadBalancerName'))]",
    "internalLoadBalancerName" : "[concat(parameters('baseName'), '-internal-lb')]",
    "internalLoadBalancerID" : "[resourceId('Microsoft.Network/loadBalancers', variables('internalLoadBalancerName'))]",
    "skuName": "Standard"
  },
  "resources" : [
    {
      "apiVersion" : "2018-12-01",
      "type" : "Microsoft.Network/publicIPAddresses",
      "name" : "[variables('masterPublicIpAddressName')]",
      "location" : "[variables('location')]",
      "sku": {
        "name": "[variables('skuName')]"
      },
      "properties" : {
        "publicIPAllocationMethod" : "Static",
        "dnsSettings" : {
          "domainNameLabel" : "[variables('masterPublicIpAddressName')]"
        }
      }
    },
    {
      "apiVersion" : "2018-12-01",
      "type" : "Microsoft.Network/loadBalancers",
      "name" : "[variables('masterLoadBalancerName')]",
      "location" : "[variables('location')]",
      "sku": {
        "name": "[variables('skuName')]"
      },
      "dependsOn" : [
        "[concat('Microsoft.Network/publicIPAddresses/', variables('masterPublicIpAddressName'))]"
      ],
      "properties" : {
        "frontendIPConfigurations" : [
          {
            "name" : "public-lb-ip",
            "properties" : {
              "publicIPAddress" : {
                "id" : "[variables('masterPublicIpAddressID')]"
              }
            }
          }
        ],
        "backendAddressPools" : [
          {
            "name" : "public-lb-backend"
          }
        ],
        "loadBalancingRules" : [
          {
            "name" : "api-internal",
            "properties" : {
              "frontendIPConfiguration" : {
                "id" :"[concat(variables('masterLoadBalancerID'), '/frontendIPConfigurations/public-lb-ip')]"
              },
              "backendAddressPool" : {
                "id" : "[concat(variables('masterLoadBalancerID'), '/backendAddressPools/public-lb-backend')]"
              },
              "protocol" : "Tcp",
              "loadDistribution" : "Default",
              "idleTimeoutInMinutes" : 30,
              "frontendPort" : 6443,
              "backendPort" : 6443,
              "probe" : {
                "id" : "[concat(variables('masterLoadBalancerID'), '/probes/api-internal-probe')]"
              }
            }
          }
        ],
        "probes" : [
          {
            "name" : "api-internal-probe",
            "properties" : {
              "protocol" : "Tcp",
              "port" : 6443,
              "intervalInSeconds" : 10,
              "numberOfProbes" : 3
            }
          }
        ]
      }
    },
    {
      "apiVersion" : "2018-12-01",
      "type" : "Microsoft.Network/loadBalancers",
      "name" : "[variables('internalLoadBalancerName')]",
      "location" : "[variables('location')]",
      "sku": {
        "name": "[variables('skuName')]"
      },
      "properties" : {
        "frontendIPConfigurations" : [
          {
            "name" : "internal-lb-ip",
            "properties" : {
              "privateIPAllocationMethod" : "Dynamic",
              "subnet" : {
                "id" : "[variables('masterSubnetRef')]"
              },
              "privateIPAddressVersion" : "IPv4"
            }
          }
        ],
        "backendAddressPools" : [
          {
            "name" : "internal-lb-backend"
          }
        ],
        "loadBalancingRules" : [
          {
            "name" : "api-internal",
            "properties" : {
              "frontendIPConfiguration" : {
                "id" : "[concat(variables('internalLoadBalancerID'), '/frontendIPConfigurations/internal-lb-ip')]"
              },
              "frontendPort" : 6443,
              "backendPort" : 6443,
              "enableFloatingIP" : false,
              "idleTimeoutInMinutes" : 30,
              "protocol" : "Tcp",
              "enableTcpReset" : false,
              "loadDistribution" : "Default",
              "backendAddressPool" : {
                "id" : "[concat(variables('internalLoadBalancerID'), '/backendAddressPools/internal-lb-backend')]"
              },
              "probe" : {
                "id" : "[concat(variables('internalLoadBalancerID'), '/probes/api-internal-probe')]"
              }
            }
          },
          {
            "name" : "sint",
            "properties" : {
              "frontendIPConfiguration" : {
                "id" : "[concat(variables('internalLoadBalancerID'), '/frontendIPConfigurations/internal-lb-ip')]"
              },
              "frontendPort" : 22623,
              "backendPort" : 22623,
              "enableFloatingIP" : false,
              "idleTimeoutInMinutes" : 30,
              "protocol" : "Tcp",
              "enableTcpReset" : false,
              "loadDistribution" : "Default",
              "backendAddressPool" : {
                "id" : "[concat(variables('internalLoadBalancerID'), '/backendAddressPools/internal-lb-backend')]"
              },
              "probe" : {
                "id" : "[concat(variables('internalLoadBalancerID'), '/probes/sint-probe')]"
              }
            }
          }
        ],
        "probes" : [
          {
            "name" : "api-internal-probe",
            "properties" : {
              "protocol" : "Tcp",
              "port" : 6443,
              "intervalInSeconds" : 10,
              "numberOfProbes" : 3
            }
          },
          {
            "name" : "sint-probe",
            "properties" : {
              "protocol" : "Tcp",
              "port" : 22623,
              "intervalInSeconds" : 10,
              "numberOfProbes" : 3
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2018-09-01",
      "type": "Microsoft.Network/privateDnsZones/A",
      "name": "[concat(parameters('privateDNSZoneName'), '/api')]",
      "location" : "[variables('location')]",
      "dependsOn" : [
        "[concat('Microsoft.Network/loadBalancers/', variables('internalLoadBalancerName'))]"
      ],
      "properties": {
        "ttl": 60,
        "aRecords": [
          {
            "ipv4Address": "[reference(variables('internalLoadBalancerName')).frontendIPConfigurations[0].properties.privateIPAddress]"
          }
        ]
      }
    },
    {
      "apiVersion": "2018-09-01",
      "type": "Microsoft.Network/privateDnsZones/A",
      "name": "[concat(parameters('privateDNSZoneName'), '/api-int')]",
      "location" : "[variables('location')]",
      "dependsOn" : [
        "[concat('Microsoft.Network/loadBalancers/', variables('internalLoadBalancerName'))]"
      ],
      "properties": {
        "ttl": 60,
        "aRecords": [
          {
            "ipv4Address": "[reference(variables('internalLoadBalancerName')).frontendIPConfigurations[0].properties.privateIPAddress]"
          }
        ]
      }
    }
  ]
}
```

04_bootstrap.json

```json
{
  "$schema" : "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion" : "1.0.0.0",
  "parameters" : {
    "baseName" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Base name to be used in resource names (usually the cluster's Infra ID)"
      }
    },
    "bootstrapIgnition" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Bootstrap ignition content for the bootstrap cluster"
      }
    },
    "sshKeyData" : {
      "type" : "securestring",
      "metadata" : {
        "description" : "SSH RSA public key file as a string."
      }
    },
    "bootstrapVMSize" : {
      "type" : "string",
      "defaultValue" : "Standard_D4s_v3",
      "allowedValues" : [
        "Standard_A2",
        "Standard_A3",
        "Standard_A4",
        "Standard_A5",
        "Standard_A6",
        "Standard_A7",
        "Standard_A8",
        "Standard_A9",
        "Standard_A10",
        "Standard_A11",
        "Standard_D2",
        "Standard_D3",
        "Standard_D4",
        "Standard_D11",
        "Standard_D12",
        "Standard_D13",
        "Standard_D14",
        "Standard_D2_v2",
        "Standard_D3_v2",
        "Standard_D4_v2",
        "Standard_D5_v2",
        "Standard_D8_v3",
        "Standard_D11_v2",
        "Standard_D12_v2",
        "Standard_D13_v2",
        "Standard_D14_v2",
        "Standard_E2_v3",
        "Standard_E4_v3",
        "Standard_E8_v3",
        "Standard_E16_v3",
        "Standard_E32_v3",
        "Standard_E64_v3",
        "Standard_E2s_v3",
        "Standard_E4s_v3",
        "Standard_E8s_v3",
        "Standard_E16s_v3",
        "Standard_E32s_v3",
        "Standard_E64s_v3",
        "Standard_G1",
        "Standard_G2",
        "Standard_G3",
        "Standard_G4",
        "Standard_G5",
        "Standard_DS2",
        "Standard_DS3",
        "Standard_DS4",
        "Standard_DS11",
        "Standard_DS12",
        "Standard_DS13",
        "Standard_DS14",
        "Standard_DS2_v2",
        "Standard_DS3_v2",
        "Standard_DS4_v2",
        "Standard_DS5_v2",
        "Standard_DS11_v2",
        "Standard_DS12_v2",
        "Standard_DS13_v2",
        "Standard_DS14_v2",
        "Standard_GS1",
        "Standard_GS2",
        "Standard_GS3",
        "Standard_GS4",
        "Standard_GS5",
        "Standard_D2s_v3",
        "Standard_D4s_v3",
        "Standard_D8s_v3"
      ],
      "metadata" : {
        "description" : "The size of the Bootstrap Virtual Machine"
      }
    }
  },
  "variables" : {
    "location" : "[resourceGroup().location]",
    "virtualNetworkName" : "[concat(parameters('baseName'), '-vnet')]",
    "virtualNetworkID" : "[resourceId('Microsoft.Network/virtualNetworks', variables('virtualNetworkName'))]",
    "masterSubnetName" : "[concat(parameters('baseName'), '-master-subnet')]",
    "masterSubnetRef" : "[concat(variables('virtualNetworkID'), '/subnets/', variables('masterSubnetName'))]",
    "masterLoadBalancerName" : "[concat(parameters('baseName'), '-public-lb')]",
    "internalLoadBalancerName" : "[concat(parameters('baseName'), '-internal-lb')]",
    "sshKeyPath" : "/home/core/.ssh/authorized_keys",
    "identityName" : "[concat(parameters('baseName'), '-identity')]",
    "vmName" : "[concat(parameters('baseName'), '-bootstrap')]",
    "nicName" : "[concat(variables('vmName'), '-nic')]",
    "imageName" : "[concat(parameters('baseName'), '-image')]",
    "controlPlaneNsgName" : "[concat(parameters('baseName'), '-controlplane-nsg')]",
    "sshPublicIpAddressName" : "[concat(variables('vmName'), '-ssh-pip')]"
  },
  "resources" : [
    {
      "apiVersion" : "2018-12-01",
      "type" : "Microsoft.Network/publicIPAddresses",
      "name" : "[variables('sshPublicIpAddressName')]",
      "location" : "[variables('location')]",
      "sku": {
        "name": "Standard"
      },
      "properties" : {
        "publicIPAllocationMethod" : "Static",
        "dnsSettings" : {
          "domainNameLabel" : "[variables('sshPublicIpAddressName')]"
        }
      }
    },
    {
      "apiVersion" : "2018-06-01",
      "type" : "Microsoft.Network/networkInterfaces",
      "name" : "[variables('nicName')]",
      "location" : "[variables('location')]",
      "dependsOn" : [
        "[resourceId('Microsoft.Network/publicIPAddresses', variables('sshPublicIpAddressName'))]"
      ],
      "properties" : {
        "ipConfigurations" : [
          {
            "name" : "pipConfig",
            "properties" : {
              "privateIPAllocationMethod" : "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', variables('sshPublicIpAddressName'))]"
              },
              "subnet" : {
                "id" : "[variables('masterSubnetRef')]"
              },
              "loadBalancerBackendAddressPools" : [
                {
                  "id" : "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.Network/loadBalancers/', variables('masterLoadBalancerName'), '/backendAddressPools/public-lb-backend')]"
                },
                {
                  "id" : "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.Network/loadBalancers/', variables('internalLoadBalancerName'), '/backendAddressPools/internal-lb-backend')]"
                }
              ]
            }
          }
        ]
      }
    },
    {
      "apiVersion" : "2018-06-01",
      "type" : "Microsoft.Compute/virtualMachines",
      "name" : "[variables('vmName')]",
      "location" : "[variables('location')]",
      "identity" : {
        "type" : "userAssigned",
        "userAssignedIdentities" : {
          "[resourceID('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('identityName'))]" : {}
        }
      },
      "dependsOn" : [
        "[concat('Microsoft.Network/networkInterfaces/', variables('nicName'))]"
      ],
      "properties" : {
        "hardwareProfile" : {
          "vmSize" : "[parameters('bootstrapVMSize')]"
        },
        "osProfile" : {
          "computerName" : "[variables('vmName')]",
          "adminUsername" : "core",
          "customData" : "[parameters('bootstrapIgnition')]",
          "linuxConfiguration" : {
            "disablePasswordAuthentication" : true,
            "ssh" : {
              "publicKeys" : [
                {
                  "path" : "[variables('sshKeyPath')]",
                  "keyData" : "[parameters('sshKeyData')]"
                }
              ]
            }
          }
        },
        "storageProfile" : {
          "imageReference": {
            "id": "[resourceId('Microsoft.Compute/images', variables('imageName'))]"
          },
          "osDisk" : {
            "name": "[concat(variables('vmName'),'_OSDisk')]",
            "osType" : "Linux",
            "createOption" : "FromImage",
            "managedDisk": {
              "storageAccountType": "Premium_LRS"
            },
            "diskSizeGB" : 100
          }
        },
        "networkProfile" : {
          "networkInterfaces" : [
            {
              "id" : "[resourceId('Microsoft.Network/networkInterfaces', variables('nicName'))]"
            }
          ]
        }
      }
    },
    {
      "apiVersion" : "2018-06-01",
      "type": "Microsoft.Network/networkSecurityGroups/securityRules",
      "name" : "[concat(variables('controlPlaneNsgName'), '/bootstrap_ssh_in')]",
      "location" : "[variables('location')]",
      "dependsOn" : [
        "[resourceId('Microsoft.Compute/virtualMachines', variables('vmName'))]"
      ],
      "properties": {
        "protocol" : "Tcp",
        "sourcePortRange" : "*",
        "destinationPortRange" : "22",
        "sourceAddressPrefix" : "*",
        "destinationAddressPrefix" : "*",
        "access" : "Allow",
        "priority" : 100,
        "direction" : "Inbound"
      }
    }
  ]
}
```

05_masters.json

```json
{
  "$schema" : "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion" : "1.0.0.0",
  "parameters" : {
    "baseName" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Base name to be used in resource names (usually the cluster's Infra ID)"
      }
    },
    "masterIgnition" : {
      "type" : "string",
      "metadata" : {
        "description" : "Ignition content for the master nodes"
      }
    },
    "numberOfMasters" : {
      "type" : "int",
      "defaultValue" : 3,
      "minValue" : 2,
      "maxValue" : 30,
      "metadata" : {
        "description" : "Number of OpenShift masters to deploy"
      }
    },
    "sshKeyData" : {
      "type" : "securestring",
      "metadata" : {
        "description" : "SSH RSA public key file as a string"
      }
    },
    "privateDNSZoneName" : {
      "type" : "string",
      "metadata" : {
        "description" : "Name of the private DNS zone the master nodes are going to be attached to"
      }
    },
    "masterVMSize" : {
      "type" : "string",
      "defaultValue" : "Standard_D8s_v3",
      "allowedValues" : [
        "Standard_A2",
        "Standard_A3",
        "Standard_A4",
        "Standard_A5",
        "Standard_A6",
        "Standard_A7",
        "Standard_A8",
        "Standard_A9",
        "Standard_A10",
        "Standard_A11",
        "Standard_D2",
        "Standard_D3",
        "Standard_D4",
        "Standard_D11",
        "Standard_D12",
        "Standard_D13",
        "Standard_D14",
        "Standard_D2_v2",
        "Standard_D3_v2",
        "Standard_D4_v2",
        "Standard_D5_v2",
        "Standard_D8_v3",
        "Standard_D11_v2",
        "Standard_D12_v2",
        "Standard_D13_v2",
        "Standard_D14_v2",
        "Standard_E2_v3",
        "Standard_E4_v3",
        "Standard_E8_v3",
        "Standard_E16_v3",
        "Standard_E32_v3",
        "Standard_E64_v3",
        "Standard_E2s_v3",
        "Standard_E4s_v3",
        "Standard_E8s_v3",
        "Standard_E16s_v3",
        "Standard_E32s_v3",
        "Standard_E64s_v3",
        "Standard_G1",
        "Standard_G2",
        "Standard_G3",
        "Standard_G4",
        "Standard_G5",
        "Standard_DS2",
        "Standard_DS3",
        "Standard_DS4",
        "Standard_DS11",
        "Standard_DS12",
        "Standard_DS13",
        "Standard_DS14",
        "Standard_DS2_v2",
        "Standard_DS3_v2",
        "Standard_DS4_v2",
        "Standard_DS5_v2",
        "Standard_DS11_v2",
        "Standard_DS12_v2",
        "Standard_DS13_v2",
        "Standard_DS14_v2",
        "Standard_GS1",
        "Standard_GS2",
        "Standard_GS3",
        "Standard_GS4",
        "Standard_GS5",
        "Standard_D2s_v3",
        "Standard_D4s_v3",
        "Standard_D8s_v3"
      ],
      "metadata" : {
        "description" : "The size of the Master Virtual Machines"
      }
    }
  },
  "variables" : {
    "location" : "[resourceGroup().location]",
    "virtualNetworkName" : "[concat(parameters('baseName'), '-vnet')]",
    "virtualNetworkID" : "[resourceId('Microsoft.Network/virtualNetworks', variables('virtualNetworkName'))]",
    "masterSubnetName" : "[concat(parameters('baseName'), '-master-subnet')]",
    "masterSubnetRef" : "[concat(variables('virtualNetworkID'), '/subnets/', variables('masterSubnetName'))]",
    "masterLoadBalancerName" : "[concat(parameters('baseName'), '-public-lb')]",
    "internalLoadBalancerName" : "[concat(parameters('baseName'), '-internal-lb')]",
    "sshKeyPath" : "/home/core/.ssh/authorized_keys",
    "identityName" : "[concat(parameters('baseName'), '-identity')]",
    "imageName" : "[concat(parameters('baseName'), '-image')]",
    "copy" : [
      {
        "name" : "vmNames",
        "count" :  "[parameters('numberOfMasters')]",
        "input" : "[concat(parameters('baseName'), '-master-', copyIndex('vmNames'))]"
      }
    ]
  },
  "resources" : [
    {
      "apiVersion" : "2018-06-01",
      "type" : "Microsoft.Network/networkInterfaces",
      "copy" : {
        "name" : "nicCopy",
        "count" : "[length(variables('vmNames'))]"
      },
      "name" : "[concat(variables('vmNames')[copyIndex()], '-nic')]",
      "location" : "[variables('location')]",
      "properties" : {
        "ipConfigurations" : [
          {
            "name" : "pipConfig",
            "properties" : {
              "privateIPAllocationMethod" : "Dynamic",
              "subnet" : {
                "id" : "[variables('masterSubnetRef')]"
              },
              "loadBalancerBackendAddressPools" : [
                {
                  "id" : "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.Network/loadBalancers/', variables('masterLoadBalancerName'), '/backendAddressPools/public-lb-backend')]"
                },
                {
                  "id" : "[concat('/subscriptions/', subscription().subscriptionId, '/resourceGroups/', resourceGroup().name, '/providers/Microsoft.Network/loadBalancers/', variables('internalLoadBalancerName'), '/backendAddressPools/internal-lb-backend')]"
                }
              ]
            }
          }
        ]
      }
    },
    {
      "apiVersion": "2018-09-01",
      "type": "Microsoft.Network/privateDnsZones/SRV",
      "name": "[concat(parameters('privateDNSZoneName'), '/_etcd-server-ssl._tcp')]",
      "location" : "[variables('location')]",
      "properties": {
        "ttl": 60,
        "copy": [{
          "name": "srvRecords",
          "count": "[length(variables('vmNames'))]",
          "input": {
            "priority": 0,
            "weight" : 10,
            "port" : 2380,
            "target" : "[concat('etcd-', copyIndex('srvRecords'), '.', parameters('privateDNSZoneName'))]"
          }
        }]
      }
    },
    {
      "apiVersion": "2018-09-01",
      "type": "Microsoft.Network/privateDnsZones/A",
      "copy" : {
        "name" : "dnsCopy",
        "count" : "[length(variables('vmNames'))]"
      },
      "name": "[concat(parameters('privateDNSZoneName'), '/etcd-', copyIndex())]",
      "location" : "[variables('location')]",
      "dependsOn" : [
        "[concat('Microsoft.Network/networkInterfaces/', concat(variables('vmNames')[copyIndex()], '-nic'))]"
      ],
      "properties": {
        "ttl": 60,
        "aRecords": [
          {
            "ipv4Address": "[reference(concat(variables('vmNames')[copyIndex()], '-nic')).ipConfigurations[0].properties.privateIPAddress]"
          }
        ]
      }
    },
    {
      "apiVersion" : "2018-06-01",
      "type" : "Microsoft.Compute/virtualMachines",
      "copy" : {
        "name" : "vmCopy",
        "count" : "[length(variables('vmNames'))]"
      },
      "name" : "[variables('vmNames')[copyIndex()]]",
      "location" : "[variables('location')]",
      "identity" : {
        "type" : "userAssigned",
        "userAssignedIdentities" : {
          "[resourceID('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('identityName'))]" : {}
        }
      },
      "dependsOn" : [
        "[concat('Microsoft.Network/networkInterfaces/', concat(variables('vmNames')[copyIndex()], '-nic'))]",
        "[concat('Microsoft.Network/privateDnsZones/', parameters('privateDNSZoneName'), '/A/etcd-', copyIndex())]",
        "[concat('Microsoft.Network/privateDnsZones/', parameters('privateDNSZoneName'), '/SRV/_etcd-server-ssl._tcp')]"
      ],
      "properties" : {
        "hardwareProfile" : {
          "vmSize" : "[parameters('masterVMSize')]"
        },
        "osProfile" : {
          "computerName" : "[variables('vmNames')[copyIndex()]]",
          "adminUsername" : "core",
          "customData" : "[parameters('masterIgnition')]",
          "linuxConfiguration" : {
            "disablePasswordAuthentication" : true,
            "ssh" : {
              "publicKeys" : [
                {
                  "path" : "[variables('sshKeyPath')]",
                  "keyData" : "[parameters('sshKeyData')]"
                }
              ]
            }
          }
        },
        "storageProfile" : {
          "imageReference": {
            "id": "[resourceId('Microsoft.Compute/images', variables('imageName'))]"
          },
          "osDisk" : {
            "name": "[concat(variables('vmNames')[copyIndex()], '_OSDisk')]",
            "osType" : "Linux",
            "createOption" : "FromImage",
            "caching": "ReadOnly",
            "writeAcceleratorEnabled": false,
            "managedDisk": {
              "storageAccountType": "Premium_LRS"
            },
            "diskSizeGB" : 128
          }
        },
        "networkProfile" : {
          "networkInterfaces" : [
            {
              "id" : "[resourceId('Microsoft.Network/networkInterfaces', concat(variables('vmNames')[copyIndex()], '-nic'))]",
              "properties": {
                "primary": false
              }
            }
          ]
        }
      }
    }
  ]
}
```

06_workers.json

```json
{
  "$schema" : "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion" : "1.0.0.0",
  "parameters" : {
    "baseName" : {
      "type" : "string",
      "minLength" : 1,
      "metadata" : {
        "description" : "Base name to be used in resource names (usually the cluster's Infra ID)"
      }
    },
    "workerIgnition" : {
      "type" : "string",
      "metadata" : {
        "description" : "Ignition content for the worker nodes"
      }
    },
    "numberOfNodes" : {
      "type" : "int",
      "defaultValue" : 3,
      "minValue" : 2,
      "maxValue" : 30,
      "metadata" : {
        "description" : "Number of OpenShift compute nodes to deploy"
      }
    },
    "sshKeyData" : {
      "type" : "securestring",
      "metadata" : {
        "description" : "SSH RSA public key file as a string"
      }
    },
    "nodeVMSize" : {
      "type" : "string",
      "defaultValue" : "Standard_D4s_v3",
      "allowedValues" : [
        "Standard_A2",
        "Standard_A3",
        "Standard_A4",
        "Standard_A5",
        "Standard_A6",
        "Standard_A7",
        "Standard_A8",
        "Standard_A9",
        "Standard_A10",
        "Standard_A11",
        "Standard_D2",
        "Standard_D3",
        "Standard_D4",
        "Standard_D11",
        "Standard_D12",
        "Standard_D13",
        "Standard_D14",
        "Standard_D2_v2",
        "Standard_D3_v2",
        "Standard_D4_v2",
        "Standard_D5_v2",
        "Standard_D8_v3",
        "Standard_D11_v2",
        "Standard_D12_v2",
        "Standard_D13_v2",
        "Standard_D14_v2",
        "Standard_E2_v3",
        "Standard_E4_v3",
        "Standard_E8_v3",
        "Standard_E16_v3",
        "Standard_E32_v3",
        "Standard_E64_v3",
        "Standard_E2s_v3",
        "Standard_E4s_v3",
        "Standard_E8s_v3",
        "Standard_E16s_v3",
        "Standard_E32s_v3",
        "Standard_E64s_v3",
        "Standard_G1",
        "Standard_G2",
        "Standard_G3",
        "Standard_G4",
        "Standard_G5",
        "Standard_DS2",
        "Standard_DS3",
        "Standard_DS4",
        "Standard_DS11",
        "Standard_DS12",
        "Standard_DS13",
        "Standard_DS14",
        "Standard_DS2_v2",
        "Standard_DS3_v2",
        "Standard_DS4_v2",
        "Standard_DS5_v2",
        "Standard_DS11_v2",
        "Standard_DS12_v2",
        "Standard_DS13_v2",
        "Standard_DS14_v2",
        "Standard_GS1",
        "Standard_GS2",
        "Standard_GS3",
        "Standard_GS4",
        "Standard_GS5",
        "Standard_D2s_v3",
        "Standard_D4s_v3",
        "Standard_D8s_v3"
      ],
      "metadata" : {
        "description" : "The size of the each Node Virtual Machine"
      }
    }
  },
  "variables" : {
    "location" : "[resourceGroup().location]",
    "virtualNetworkName" : "[concat(parameters('baseName'), '-vnet')]",
    "virtualNetworkID" : "[resourceId('Microsoft.Network/virtualNetworks', variables('virtualNetworkName'))]",
    "nodeSubnetName" : "[concat(parameters('baseName'), '-worker-subnet')]",
    "nodeSubnetRef" : "[concat(variables('virtualNetworkID'), '/subnets/', variables('nodeSubnetName'))]",
    "infraLoadBalancerName" : "[parameters('baseName')]",
    "sshKeyPath" : "/home/capi/.ssh/authorized_keys",
    "identityName" : "[concat(parameters('baseName'), '-identity')]",
    "imageName" : "[concat(parameters('baseName'), '-image')]",
    "copy" : [
      {
        "name" : "vmNames",
        "count" :  "[parameters('numberOfNodes')]",
        "input" : "[concat(parameters('baseName'), '-worker-', variables('location'), '-', copyIndex('vmNames', 1))]"
      }
    ]
  },
  "resources" : [
    {
      "apiVersion" : "2019-05-01",
      "name" : "[concat('node', copyIndex())]",
      "type" : "Microsoft.Resources/deployments",
      "copy" : {
        "name" : "nodeCopy",
        "count" : "[length(variables('vmNames'))]"
      },
      "properties" : {
        "mode" : "Incremental",
        "template" : {
          "$schema" : "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
          "contentVersion" : "1.0.0.0",
          "resources" : [
            {
              "apiVersion" : "2018-06-01",
              "type" : "Microsoft.Network/networkInterfaces",
              "name" : "[concat(variables('vmNames')[copyIndex()], '-nic')]",
              "location" : "[variables('location')]",
              "properties" : {
                "ipConfigurations" : [
                  {
                    "name" : "pipConfig",
                    "properties" : {
                      "privateIPAllocationMethod" : "Dynamic",
                      "subnet" : {
                        "id" : "[variables('nodeSubnetRef')]"
                      }
                    }
                  }
                ]
              }
            },
            {
              "apiVersion" : "2018-06-01",
              "type" : "Microsoft.Compute/virtualMachines",
              "name" : "[variables('vmNames')[copyIndex()]]",
              "location" : "[variables('location')]",
              "tags" : {
                "kubernetes.io-cluster-ffranzupi": "owned"
              },
              "identity" : {
                "type" : "userAssigned",
                "userAssignedIdentities" : {
                  "[resourceID('Microsoft.ManagedIdentity/userAssignedIdentities/', variables('identityName'))]" : {}
                }
              },
              "dependsOn" : [
                "[concat('Microsoft.Network/networkInterfaces/', concat(variables('vmNames')[copyIndex()], '-nic'))]"
              ],
              "properties" : {
                "hardwareProfile" : {
                  "vmSize" : "[parameters('nodeVMSize')]"
                },
                "osProfile" : {
                  "computerName" : "[variables('vmNames')[copyIndex()]]",
                  "adminUsername" : "capi",
                  "customData" : "[parameters('workerIgnition')]",
                  "linuxConfiguration" : {
                    "disablePasswordAuthentication" : true,
                    "ssh" : {
                      "publicKeys" : [
                        {
                          "path" : "[variables('sshKeyPath')]",
                          "keyData" : "[parameters('sshKeyData')]"
                        }
                      ]
                    }
                  }
                },
                "storageProfile" : {
                  "imageReference": {
                    "id": "[resourceId('Microsoft.Compute/images', variables('imageName'))]"
                  },
                  "osDisk" : {
                    "name": "[concat(variables('vmNames')[copyIndex()],'_OSDisk')]",
                    "osType" : "Linux",
                    "createOption" : "FromImage",
                    "managedDisk": {
                      "storageAccountType": "Premium_LRS"
                    },
                    "diskSizeGB": 128
                  }
                },
                "networkProfile" : {
                  "networkInterfaces" : [
                    {
                      "id" : "[resourceId('Microsoft.Network/networkInterfaces', concat(variables('vmNames')[copyIndex()], '-nic'))]",
                      "properties": {
                        "primary": true
                      }
                    }
                  ]
                }
              }
            }
          ]
        }
      }
    }
  ]
}
