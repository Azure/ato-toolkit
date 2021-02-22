# Mattermost

**Estimated Time:**

* Smart Hands Preparation Time: 15 mins
* Deployment Time: 20 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* [Porter](https://porter.sh) - included in install bits
* Access to a functional Openshift 3.11 cluster

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, copy files to the bastion, and deploy into the kubernetes cluster.

1. Open `./deployment/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.

1. In the `AZ CLI Configuration` section, update the following values:

    ```powershell
    [string] $DepArgs.SubscriptionId = ""
    [string] $DepArgs.TenantId = ""
    ```

1. (optional) Change the PostgreSQL username from its default values

    ```powershell
    [string] $DepArgs.PostgresUsername = "postgres"
    ```

1. (optional) Change the PostgreSQL password from a generated value

    ```powershell
    [string] $DepArgs.PostgresPassword = Get-RandomString 15 -IncludeNumber
    ```

1. (Optional) Update the default namespace for Mattermost from its default value

    ```powershell
    [string] $DepArgs.Namespace = "ns-mattermost"
    ```

1. Update the `AppUrl` to use the same DNS that was setup in the OCP deployment. The ip address that this should resolve to is the `RouterPrivateClusterIp` from the OCP deployment. Below is the default value.

    ```powershell
    [string] $DepArgs.AppUrl = "mattermost.apps.dev-openshift.com"
    ```

1. You will need to find the ip for the `ContainerRegistry` from the OCP deployment. Then vm names ends in `SYDR-001v`.

    ```powershell
    [string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
    ```

    > **[!TIP]**
    > You can run the following command to get the ip address of the container registry for OCP. If you changed the naming of the OCP cluster, you will need to account for that.
    >
    > `az vm show -g AZS-DEP-OCP-RG94 -n BETA-EAST-SYDR-001v -d --query privateIps -o tsv`

1. The `SshKey` is the default setup from the OCP deployment. If a new key was generated, then the value much be updated here and the key must be placed in the `/certs/` folder.

    ```powershell
    [string] $DepArgs.SshKey = "cfs-cert"
    ```

1. (Optional) Update email and smtp settings.  If you wish to enable email notifications, update the following values in the variable file.

    ```powershell
    [bool] $DepArgs.EmailNotifications = $false
    [bool] $DepArgs.EnableSmtpAuth = $false
    [string] $DepArgs.SmtpUsername = "user@domain.com"
    [string] $DepArgs.SmtpPassword = ""
    [string] $DepArgs.SmtpServer = "smtp.office365.com"
    [int] $DepArgs.SmtpPort = 587
    ```

1. If you changed the naming for the OCP cluster, you will need to update the `ResourceGroup` and `BastionMachineName` to match those changes.

1. To begin the deployment:
    1. Open `pwsh.lnk`
    1. Navigate to the `deployment` folder beside these instructions
    1. Run the following command to execute install file and start the deployment

    ```powershell
    ./install.ps1 -VariableFile ./deployment.vars.ps1
    ```

## Post Deployment Steps (success criteria)

The output from the installation will complete in a matter of minutes, however, the pods that get spun up will take upwards to 20 minutes to finish post installation steps.

After waiting, open a browser and navigate to **https://[AppUrl]/**. Remember that the OCP installation uses self signed certificates by default. The means that when opening Mattermost, you will have to chose to continue past an untrusted certificate because the issuer is not know. However, we know that we can trust the certificate because we just completed the install.

You will be prompted to create an initial administrative account when first visiting the landing page. After creation, you'll be able to log in with the account you just created and then begin configuring Mattermost for additional users.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deployment/output/` folder. Look there first for any issues. There are no known issues with this deployment.
