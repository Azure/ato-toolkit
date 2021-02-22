# Kibana

**Estimated Time:**

- Smart Hands Preparation Time: 15 mins
- Deployment Time: 15 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, copy files to the bastion, and deploy into the kubernetes cluster.

1. Open `./deployment/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.
2. In the `AZ CLI Configuration` section, update the following values:
    ```powershell
    [string] $DepArgs.SubscriptionId = ""

    [string] $DepArgs.TenantId = ""
    ```

3. Update the `AppUrl` to use the same DNS that was setup in the OCP deployment. The ip address that this should resolve to is the `RouterPrivateClusterIp` from the OCP deployment. Below is the default value.
    ```powershell
    [string] $DepArgs.AppUrl = "kibana.apps.dev-openshift.com"
    ```

4. You will need to find the ip for the `ContainerRegistry` from the OCP deployment. Then vm names ends in `SYDR-001v`.
    ```powershell
    [string] $DepArgs.ContainerRegistry = "10.3.103.4:5000"
    ```
    > [!TIP]
    > You can run the following command to get the ip address of the container registry for OCP. If you changed the naming of the OCP cluster, you will need to account for that.
    >
    > `az vm show -g AZS-DEP-OCP-RG94 -n BETA-EAST-SYDR-001v -d --query privateIps -o tsv` 

5. The `SshKey` is the default setup from the OCP deployment. If a new key was generated, then the value much be updated here and the key must be placed in the `/certs/` folder.
6. If you changed the naming for the OCP cluster, you will need to update the `ResourceGroup` and `BastionMachineName` to match those changes.
7. If you changed the naming of the elastic deployment, then you will need to update the `KeyVault` to match that name.
8. To begin the deployment:
    1. Open `tools/powershell-core/Windows/install/pwsh.exe` from the root of this repo
    2. Run the following command to set the Execution Policy for PowerShell
    ```powershell
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser
    ```
    1. Answer [Y] Yes to the Execution Policy Change prompt
    2. Navigate to the `deployment` folder beside these instructions
    3. Run the following command to execute install file and start the deployment
    ```powershell
    ./install.ps1 -VariableFile deployment.vars.ps1
    ```

## Post Deployment Steps (success criteria)

When the installation completes, open a browser and navigate to the `AppUrl` with `https` appended in the front. Remember that the OCP installation uses self signed certificates by default. The means that when opening kibana, you will have to chose to continue past an untrusted certificate because the issuer is not know. However, we know that we can trust the certificate because just completed the install.

> [!TIP]
> If you would like to login you will have to go to the elastic keyvault to get the key named `elasticPassword`. Then you can login using username: elastic with that password.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deployment/output/` folder. Look there first for any issues. There are no known issues with this deployment.
