# Cluster on-boarding 
This folder contains the required scripts to on-board a kubernetes cluster into a pre existing c12 platform

# Prerequisites
 * Kubernetes cluster to adopt.
 * kubectl already configured for the cluster to adopt.
 * ACR Repository configured with pull permissions for the service principal running kubernetes
 * az cli, correctly logged and set with the default subscription where the cluster and the ACR is.
 * git with ssh credentials to pull and push to cluster-state repository
 * helm v3 cli
 * envsubst


# Onbarding
### Creating the .ini file
The onboarding script takes it's input parameters from an .ini file, that needs to be created *prior* running the script.
Please note that this preparation is not required when this script is being run by bootstrapping as the necesary values are pre populated. 

```ini
[cluster]
acr_name=
service_principal_application_id=
service_principal_password=
name=

[c12]
prefix=

[github]
org=
access-token=

[org]
break-glass_group_id=breakglassgroupguid
read-only_group_id=readonlygroupguid
sre_group_id=sregroupguid


[terraform]
container-rg=
container-name=
storage-account-name=
arm-access-key=
```

### Running the script
Once the .ini file has been created, the script needs to be called passing the file name as argument, ie:
```
src/runtime/cluster-on-boarding/scripts/on_board_cluster.sh -f config.ini
```