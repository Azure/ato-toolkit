# OpenEBS

**Estimated Time:**

* Smart Hands Preparation Time: 60 mins
* Deployment Time: 60 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* [Porter](https://porter.sh) - included in install bits
* Access to a functional Openshift 3.11 cluster

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, copy files to the bastion, and deploy into the kubernetes cluster.

1. Open `./deploy/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.

1. In the `AZ CLI Configuration` section, update the following values:

    ```powershell
    [string] $DepArgs.Username = ""
    [string] $DepArgs.Tenant = ""
    [string] $DepArgs.Paswd = ""
    ```

1. (Optional) Update the default Disk names (at this time, the names of the disk will all be appended with a numeric value to represent the order in which they were created)

    ```powershell
    [string] $DepArgs.DriveName = "OpenEBSDisk00"
    ```

1. You will need to find the ip for the `ContainerRegistry` from the OCP deployment. Then vm names ends in `SYDR-001v`.

    ```powershell
    [string] $DepArgs.ContainerRegistry = "10.50.101.4:5000"
    ```

    > **[!TIP]**
    > You can run the following command to get the ip address of the container registry for OCP. If you changed the naming of the OCP cluster, you will need to account for that.
    >
    > `az vm show -g AZS-DEP-OCP-RG94 -n BETA-EAST-SYDR-001v -d --query privateIps -o tsv`

1. You will need to set the BastionIP as we will run an oc command against it and move the CNAB files to it.
    ```powershell
    [string] $DepArgs.BastionMachineIp = ""
    ```

1. The `SshKey` is the default setup from the OCP deployment. If a new key was generated, then the value much be updated here and the key must be placed in the `/certs/` folder.

    ```powershell
    [string] $DepArgs.SshKey = "cfs-cert"
    ```

1. If a cert is required to use the OCP bastion, Copy the cert used for az commands to the OCP bastion (scp)
    1. The NSSCertPath variable must be set to the filepath of the cert
    ```powershell
    [string] $DepArgs.NSSCertPath = "/foo/bar/fizz/buzz.pem"
    ```

1. Some variables will need to be updated based on a per environment deployment:
    ```powershell
    [string] $DepArgs.ResourceGroup = "$($ProductLine)-$($Environment)-YNGRY-OCP-RG01"

    ```

1. To begin the deployment:

    ```powershell
    ./install.ps1 #-VariableFile ./deployment.vars.ps1
    ```

## Post Deployment Steps (success criteria)

* We can verify the existence of the storage class:
    ```
    kubectl get storageclass
    ```
    We should see several storageclasses listed, however the one we need to verify is: "openebs-sc-statefulset"

* Additionally, we need to verify disks have been claime for use with the cluster:
    ```
    kubectl get blockdevices -n openebs
    ```
* Verify multiple blockdevices have a Status of "Claimed"

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deploy/output/` folder. Look there first for any issues. There are no known issues with this deployment.
