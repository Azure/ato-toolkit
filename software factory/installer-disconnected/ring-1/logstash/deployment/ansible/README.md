# **Logstash Installer**

Ansible scripts are normally ran from a jump box or remote host.  In order to execute Ansible playbooks, you must have Ansible installed on the host.  If you haven't installed Ansible yet, you can run one of the following commands:  

If you have a RedHat subscription run:
`sudo yum install -y ansible`

If you do not have a RedHat subscription run:
`sudo yum install  https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y`
`sudo yum update -y`
`sudo yum repolist`
`sudo yum install ansible -y`

**High Level Instructions:**
1) Copy Ansible script to jump box
2) Install Ansible
3) Copy SSH key(s) to same directory as Ansible hosts file
4) Modify hosts file for deployment
5) Modify /defaults/main.yml file (Or use flags at deployment)
6) Run Ansible playbook

# Pre-Installation Configuration
## **Hosts File**
### **Examle hosts file**  
>`[linux_systems]`  
`ESLS ansible_ssh_user=cfscloudadmin ansible_ssh_private_key_file=id_rsa`  

&nbsp;

### **Groups**  
|  Group Name  |  Description  |
|--------------|---------------|
|[linux_systems]|At this time, ony linux systems are supported in the playbook|

&nbsp;

### **Hosts Items**
|  Host Item  |  Default Value  |  Description  |
|-------------|-----------------|---------------|
|HOSTNAME|ESLS|Hostname of target VM|
|ansible_ssh_user|cfscloudadmin|SSH user for target VM|
|ansible_ssh_private_key_file|id_rsa|SSH key for target VM user|

&nbsp;

## **defaults/main.yml Configuration**
***NOTE:** These can be defined at runtime.  See **"Running The Ansible Script"** below*

### **Variables**
|  Variable Name  |  Default Value  |  Description  |
|-----------------|-----------------|---------------|
|logstash_version|7.x|Logstash version|
|logstash_listen_port_auditbeat|5040|Port number for auditbeat|
|logstash_listen_port_filebeat|5044|Port number for filebeat|
|logstash_pipeline_host|Name of VM|Hostname for VM ex. D_VAZ_ESLS_001v|
|logstash_elasticsearch_ip|0.0.0.0|IP of Elasticsearch master ex. 10.210.3.5|
|logstash_elasticsearch_port|9200|Port number of Elasticsearch|
|logstash_local_syslog_path|/var/log/syslog|Syslog path|
|logstash_monitor_local_syslog|true/false|Monitor local syslog?|
|logstash_dir|/usr/share/logstash|Logstash Directory|
|logstash_ssl_dir|/etc/pki/logstash|Logstash SSL directory|
|logstash_ssl_certificate_file|filepath|SSL certificate file location|
|logstash_ssl_key_file|filepath|SSL key file location|
|logstash_enabled_on_boot|true/false|Enable logstash on boot?|
|logstash_install_plugins|ex. logstash-input-beats|Plugins to install, one per line ex. -logstash-input-beats [Reference](https://github.com/logstash-plugins)|
|es_auditbeat_user|username|Username for auditbeat pipeline output|
|es_auditbeat_password|password|Password for auditbeat pipeline output|
|es_filebeat_user|username|Username for filebeat pipeline output|
|es_filebeat_password|password|Password for filebeat pipeline output|
|es_cfs_user|username|Username for CFS pipeline output|
|es_cfs_password|password|Password for CFS pipeline output|
|jdbc_ip|0.0.0.0|IP address for CFS database (for connection string)
|jdbc_port|0000|Port number for CFS database (for connection string)
|jdbc_database_name|database_name|Database name for CFS database (for connection string)
|jdbc_user|username|Username for CFS database|
|jdbc_password|password|Password for CFS database|

&nbsp; 

&nbsp; 

# Running The Ansible Script

## Pre-Configured Vars
If the /defaults/main.yml file has already been configured, run the following command from the directory of the install.yml file:  
`sudo ansible-playbook install.yml -i hosts`  

## Run-Time Configured Vars
If the /defaults/main.yml file has not been configured and you would rather add some variables at the command prompt, run the following command from the directory of the install.yml file using the -e following the script:  
`sudo ansible-playbook install.yml -i hosts`  
`-e "logstash_elasticsearch_ip=0.0.0.0"`  
`-e "logstash_listen_port_auditbeat=5040"`  
`-e "logstash_version=7.6.1"`
