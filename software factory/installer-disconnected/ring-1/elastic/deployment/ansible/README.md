# **Elasticsearch Installer**

Ansible scripts are normally ran from a jump box or remote host.  In order to execute Ansible playbooks, you must have Ansible installed on the host.  If you haven't installed Ansible yet, you may run the following command:  
`sudo yum install -y ansible`  
***NOTE:** Ansible minimum version: 2.8*

**HIGH LEVEL INSTRUCTIONS:**
1) Copy Ansible script to jump box
2) Install Ansible
3) Copy SSH key(s) to same directory as Ansible hosts file
4) Modify hosts file for deployment
5) Modify /group_vars/all/vars.yml file (Or use flags at deployment)
6) Run Ansible playbook

# Pre-Installation Configuration
## **Hosts File**
### **EXAMPLE HOSTS FILE**  
>`[initial-master-node]`  
`ESNM1 ansible_ssh_user=cfscloudadmin ansible_ssh_private_key_file=id_rsa jvm1=-Xms4g jvm2=-Xmx4g masterNode=true dataNode=false`  
`[additional-master-nodes]`  
`ESNM2 ansible_ssh_user=cfscloudadmin ansible_ssh_private_key_file=id_rsa jvm1=-Xms4g jvm2=-Xmx4g masterNode=true dataNode=false`  
`[data-nodes]`  
`ESND1 ansible_ssh_user=cfscloudadmin ansible_ssh_private_key_file=id_rsa jvm1=-Xms4g jvm2=-Xmx4g masterNode=false dataNode=true`

&nbsp;

### **GROUPS**  
|  Group Name  |  Description  |
|--------------|---------------|
|[initial-master-node]|There should only be one node under this group (Master Node 1)|
|[additional-master-nodes]|Any other master nodes (Master Node 2 ... Master Node n)|
|[data-nodes]|All data nodes listed here|

&nbsp;

### **HOST ITEMS**
|  Host Item  |  Default Value  |  Description  |
|-------------|-----------------|---------------|
|HOSTNAME|ESNM|Hostname of target VM|
|ansible_hosts|0.0.0.0|IP address of target VM|
|ansible_ssh_user|cfscloudadmin|SSH user for target VM|
|ansible_ssh_private_key_file|id_rsa|SSH key for target VM user|
|jvm1|-Xms4g|JVM suggested heap size.  Must be 50% of VM RAM size. Default value is for an 8GB VM.  Cannot be more than 31.  For VMs with 64GB or more, use 31.|
|jvm2|-Xmx4g|JVM max heap size.  Must be 50% of VM RAM size. Default value is for an 8GB VM.  Cannot be more than 31.  For VMs with 64GB or more, use 31.|
|masterNode|true|Is master node? (true/false)|
|dataNode|false|Is data node? (true/false)|

&nbsp;

## **Vars.yml Configuration**
***NOTE:** These can be defined at runtime.  See **"Running The Ansible Script"** below*

### **VARIABLES**
|  Variable Name  |  Default Value  |  Description  |
|-----------------|-----------------|---------------|
|ES_CLUSTER_NAME|es-IL4|Cluster name|
|ES_INITIAL_MASTER_HOSTNAME|ESNM1|Initial master hostname, must match hostname in the hosts file.|
|ES_INITIAL_MASTER_IP|0.0.0.0|Initial master IP address, must match IP address of the initial master in the hosts file.|
|ES_INITIAL_MASTER_CA_PASS|SUPER_SECRET_PASSWORD|CA pass - randomly generated|
|ELASTICSEARCH_VERSION|7.6.2|Elasticsearch version.  This version must be the same or newer than the other elastic programs (Kibana, Logstash, Filebeat, Auditbeat, etc...)|
|ES_DEFAULT_PORT_1|9200|Elasticsearch public port number|
|ES_DEFAULT_PORT_2|9300|Elasticsearch internal cluster port number|
|ES_DATA_DISK_SIZE|64GB|Data disk size for data nodes.  This should be calculated based on deployment / environments requirements|
|ES_DATA_PATH|/data|Mount path for data drives|
|USER_LOCATION|/etc/elasticsearch/userdest|Path to store generated default user passwords|
|OFFLINE_DEPLOYMENT|false|Offline deployment true/false|
|azure_plugin.storage_account_name|STORAGE_ACCOUNT_NAME|Azure storage account name|
|azure_plugin.storage_account_key|STORAGE_ACCOUNT_KEY|Azure storage account key|
|azure_plugin.gov_cloud|true|Is in Azure Gov Cloud (true/false)|
&nbsp; 

&nbsp; 

# Running The Ansible Script
## For Offline Deployment
To deploy offline, there is a variable OFFLINE_DEPLOYMENT that should be set to true.  In the /ar0-initial-install/bin folder, the RPM for elasticsearch should be saved.  The naming convention for the RPM file should be the same as downloaded from elasticsearch.  The script utilizes the ELASTICSEARCH_VERSION in the RPM file name.  Please make sure that the RPM file matches the same version as ELASTICSEARCH_VERSION variable.
`elasticsearch-{{ ELASTICSEARCH_VERSION }}-x86_64.rpm`

## Pre-Configured Vars
If the /group_vars/all/vars.yml file has already been configured, run the following command from the directory of the elasticinstall.yml file:  
`sudo ansible-playbook elasticinstall.yml -i hosts`  

## Run-Time Configured Vars
If the /group_vars/all/vars.yml file has not been configured, run the following command from the directory of the elasticinstall.yml file using the -e following the script:  
```
sudo ansible-playbook elasticinstall.yml -i hosts  
-e "ES_CLUSTER_NAME=cluster-name"
-e "ES_INITIAL_MASTER_HOSTNAME=HOSTNAME"  
-e "ES_INITIAL_MASTER_IP=0.0.0.0"
-e "ES_INITIAL_MASTER_CA_PASS=PASSWORD"
-e "ELASTICSEARCH_VERSION=7.6.2"
-e "ES_DEFAULT_PORT_1=9200"
-e "ES_DEFAULT_PORT_2=9300"  
-e "ES_DATA_DISK_SIZE=64GB"  
-e "ES_DATA_PATH=/data"
-e "USER_LOCATION=/etc/elasticsearch/userdest"
-e "OFFLINE_DEPLOYMENT=false"
```
