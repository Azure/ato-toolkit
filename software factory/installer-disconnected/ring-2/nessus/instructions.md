# Nessus

**Estimated Time:**

* Smart Hands Preparation Time: 15 mins
* Deployment Time: 20 mins

## Prerequisites

* Download the porter bundle from the [ReadMe](../../ReadMe.md) and place in the `deployment` folder.
* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* [Porter](https://porter.sh) - included in install bits
* Access to a functional Openshift 3.11 cluster

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, copy files to the bastion, and deploy into the kubernetes cluster.

1. Download the porter bundle from the [ReadMe](../../ReadMe.md) and place in the `deployment` folder.
1. Open `./deployment/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.

1. In the `AZ CLI Configuration` section, update the following values:

    ```powershell
    [string] $DepArgs.SubscriptionId = ""
    [string] $DepArgs.TenantId = ""
    ```

1. (Optional) Update UseRegistryCredential boolean

    ```powershell
    [bool] $DepArgs.UseRegistryCredential = $false
    # if above value is true, modify the following two settings
    [string] $DepArgs.RegistryUserName = ""
    [string] $DepArgs.RegistryUserEmail = ""
    ```

1. Update the `AppUrl` to use the same DNS that was setup in the OCP deployment. The ip address that this should resolve to is the `RouterPrivateClusterIp` from the OCP deployment. Below is the default value.

    ```powershell
    [string] $DepArgs.AppUrl = "nessus.apps.dev-openshift.com"
    ```

1. You will need to find the ip for the `ContainerRegistry` from the OCP deployment. Then vm names ends in `SYDR-001v`.

    ```powershell
    [string] $DepArgs.ContainerRegistry = "1.1.1.1:5000"
    ```

    > **[!TIP]**
    > You can run the following command to get the ip address of the container registry for OCP. If you changed the naming of the OCP cluster, you will need to account for that.
    >
    > `az vm show -g AZS-DEP-OCP-RG01 -n BETA-EAST-SYDR-001v -d --query privateIps -o tsv`

1. The `SshKey` is the default setup from the OCP deployment. If a new key was generated, then the value much be updated here and the key must be placed in the `/certs/` folder.

    ```powershell
    [string] $DepArgs.SshKey = "cfs-cert"
    ```

1. If you changed the naming for the OCP cluster, you will need to update the `ResourceGroup` and `BastionMachineName` to match those changes.

1. To begin the deployment:
    1. Open `tools/powershell-core/Windows/install/pwsh.exe` from the root of this repo
    1. Run the following command to set the Execution Policy for PowerShell

    ```powershell
    Set-ExecutionPolicy Bypass -Scope CurrentUser
    ```

    1. Answer [Y] Yes to the Execution Policy Change prompt
    1. Navigate to the `deployment` folder beside these instructions
    1. Run the following command to execute install file and start the deployment

    ```powershell
    ./install.ps1 -VariableFile ./deployment.vars.ps1
    ```

## Post Deployment Steps (success criteria)

The output from the installation will complete in a matter of minutes, however, the pods that get spun up will take upwards to 20 minutes to finish post installation steps.

After waiting, open a browser and navigate to https://`AppUrl`. Remember that the OCP installation uses self signed certificates by default. The means that when opening Nessus, you will have to chose to continue past an untrusted certificate because the issuer is not know. However, we know that we can trust the certificate because we just completed the install.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deployment/output/` folder. Look there first for any issues. There are no known issues with this deployment.
