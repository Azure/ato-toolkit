# Fortify

**Estimated Time:**

- Smart Hands Preparation Time: 15 mins
- Deployment Time: 30 mins

## Prerequisites

* Download the porter bundle from the [ReadMe](../../ReadMe.md) and place in the `deployment` folder.
* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits
* [Porter](https://porter.sh) - included in install bits
* Access to a functional Openshift 3.11 cluster
* Access to the container registry within the OCP 3.11 environment

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, copy files to the bastion, and deploy into the kubernetes cluster.

1. Download the porter bundle from the [ReadMe](../../ReadMe.md) and place in the `deployment` folder.
1. Open `./deploy/deployment.vars.ps1` in a text editor. We're going to change a few variable values before starting the deployment.
2. In the `AZ CLI Configuration` section, update the following values:

    ```powershell
        [string] $DepArgs.SubscriptionId = ""

        [string] $DepArgs.TenantId = ""
    ```
3. In the `AZ CLI Configuration` section, update the following values:
    ```powershell
        
        [string] $DepArgs.BastionMachineIP = "0.0.0.0"

    ```

4. Update the AppUrl to use the same DNS that was setup in the OCP deployment. The ip address that this should resolve to is the RouterPrivateClusterIp from the OCP deployment. Below is the default value.
    ```powershell
        [string] $DepArgs.AppUrl = "fortifyssc.apps.dev-openshift.com"
    ```
5. You will need to find the ip for the ContainerRegistry from the OCP deployment. Then vm names ends in SYDR-001v.
    ```powershell
    [string] $DepArgs.ContainerRegistry = "0.0.0.0:5000"
    ```
    > [!TIP] You can run the following command to get the ip address of the container registry for OCP. If you changed the naming of the OCP cluster, you will need to account for that.
    >
    > `az vm show -g AZS-DEP-OCP-RG94 -n BETA-EAST-SYDR-001v -d --query privateIps -o tsv`

6. The SshKey is the default setup from the OCP deployment. If a new key was generated, then the value much be updated here and the key must be placed in the /certs/ folder.
        ```powershell
        [string] $DepArgs.SshKey = "cfs-cert"
        ```
7. (Optional) Update the registry credentials to access a private container registry
        ```powershell
        [bool] $DepArgs.IsInsecureRegistry = $true
        [bool] $DepArgs.UsePrivateReg = $False
        #If the above is true the following will have to be modified
        [bool] $DepArgs.UseRegistryCredential = $False
        [string] $DepArgs.PrivateRegUn = "aUser"
        [string] $DepArgs.PrivateRegPw = "aPassword"
        [string] $DepArgs.PrivateRegEmail = "registry@somecompany.com"
        ```

8. Ensure the license file for fortify is placed on the ocp bastion server at the `/home/ocpadmin/fortify.license` location.
    1. `scp -i certs/cfs-cert ./fortify.license ocpadmin@<ocpbastionip>:/home/ocpadmin/fortify.license`

9. To begin the deployment:
    1. Open `tools/powershell-core/Windows/install/pwsh.exe` from the root of this repo
    2. Run the following command to set the Execution Policy for PowerShell
    ```powershell
    Set-ExecutionPolicy Unrestricted -Scope CurrentUser
    ```
    3. Answer [Y] Yes to the Execution Policy Change prompt
    4. Navigate to the `deploy` folder beside these instructions
    5. Run the following command to execute install file and start the deployment
    ```powershell
    ./install.ps1 -VariableFile deployment.vars.ps1
    ```

## Post Deployment Steps (success criteria)

After the software has been deployed, navigate to the value of AppUrl in a web browser. The Fortify login page should display. On first run you will be required to set new admin credentials. Default Username:Password is admin:admin. This is a function of the Fortify SSC application, not the container.

## Acceptable / Expected Errors
- If the namespace exists prior to deployment, an error noting the namespace already exists may be observed.

## Troubleshooting Guide (error mitigation plan)

All installation logs are output to the `./deploy/output/` folder. Look there first for any issues.

1. If you see an error regarding a namespace conflict you may have to adjust the value of $DepArgs.AppName in deployment.vars.ps1. The value of $DepArgs.AppName must be unique from any other namespace in the OCP cluster.
2. Part of the installation is to stand up and connect to the Postgresql database. The installer will check for a connection to the database if possible. If this does not occur, verify your machine can connect to the cluster and reattempt the installation.
3. If at any point the installation fails, navigate to the folder called `fortifyssc` on the Openshift Bastion server and execute `porter uninstall fortifyssc -c ./credentials.json -p ./params.json` to uninstall the resources generated by the installer. Errors or warnings may be displayed if particular resources were not created during the failed installation, but the uninstall action will allow the operator to restart the installation from a clean state.
