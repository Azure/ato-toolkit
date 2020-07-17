# Instructions

Follow these instructions to deploy Zero Trust blueprint in an offline (disconnected from from internet, environment such as Azure Stack and other private Azure configurations). If deploying to an environment which does have internet connectivity, refer the [instructions for online version](../zero-trust-architecture/README.md).

This automation has dependencies for an external package that needs to be downloaded from the internet, to enable the instructions which are divided into 4 parts. Part 1- downloads and packages all the dependencies, Part 2- outlines how securely transfer all the automation code, documentation and downloaded dependencies into offline environment. Part 3- uploads all the dependencies into Azure storage account which is accessible from offline (disconnected from public internet) environment. This is required to make sure automation can access to these artifacts at the time of deployment. And lastly Part 4- initiate deployment. Following instructions guide for each one of these parts in detail.

## Part-1 (download and package dependencies)

Run these steps from an internet connected computer. Download and packaging of dependencies has to be done separately for Windows and Linux OS based configurations. If your deployment involves either only Windows or Linux OS, follow only the respective section and ignore the other one. However, if your deployment involves both, execute both the steps and merge the outputs before transferring to offline environment.

### Windows

For Windows bases OSes the dependencies include PowerSTIG and other DSC configurations. For complete list of PowerShell modules being downloaded, refer '.\scripts\DownloadPowerShellModules.ps1'.

#### Prerequisites for Windows

1. Windows Server 2019 or Windows 10 with Powershell 5.1 installed. To set one up easily in Azure [follow these steps](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal).
2. Git installed. [how to](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
3. Outbound Internet connectivity to 'www.powershellgallery.com'.
4. Azure Powershell module installed. [how to](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.4.0).

#### Instructions for Windows dependency preparation

1. Open an elevated (Admin) PowerShell terminal and execute following commands.

    ```azurepowershell
    Import-Module Az
    Set-ExecutionPolicy RemoteSigned
    ```

2. Run following command to clone Azure ato-toolkit repository to your local working directory.

    `git clone https://github.com/Azure/ato-toolkit.git`

    > [!TIP]
    > Run `dir` to verify content of directory.

3. Run following command to change the directory.

    `cd ato-toolkit\automation\zero-trust-architecture-offline`

4. Run following command to download all the required PowerShell module dependencies.

    `.\scripts\DownloadPowerShellModules.ps1`

5. Run following command to package all the dependencies.

    `.\scripts\build.ps1`

### Linux

For Linux bases OSes the dependencies include DISA STIG files and following instructions will download and create offline yum package for to be used for offline deployment. For more information on what's being downloaded, refer '.\scripts\build.sh'.

#### Prerequisites for Linux

1. CentOS 7.7. To set one up easily in Azure [follow these steps](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal).
2. Git installed. [how to](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
3. Outbound Internet connectivity.

#### Instructions for Linux dependency preparation

1. Run  following command to clone Azure ato-toolkit repository to your local working directory.

    `git clone https://github.com/Azure/ato-toolkit.git`

    > [!TIP]
    > Run `dir` to verify content of directory.

2. Run following command to change the directory.

    `cd ato-toolkit/automation/zero-trust-architecture-offline`

4. Run following command to download all the required PowerShell module dependencies.

    `.\scripts\DownloadPowerShellModules.ps1`

5. Run following command to package all the dependencies.

    `.\scripts\build.ps1`

## Part 2 (transfer automation code/scripts, documentation and downloaded dependencies into offline environment)

By now you would have successfully executed Windows and/or Linux sections of Part 1. If both are applicable, make sure your have merged the downloaded dependencies from both Windows and Linux computers. All the downloaded dependencies are placed in '.\zero-trust-architecture-offline\scripts\dependencies' folder.

Now, using your preferred method of data transfer, transfer folder 'zero-trust-architecture-offline' and all of its content (including all code/scripts, documentation and downloaded packages files) onto a computer connected to offline environment. Rest of the steps will be executed from within offline environment.

### Prerequisites for computer in offline environment

1. PowerShell installed. [how to](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7).
2. Azure Powershell module installed. [how to](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.4.0).

## Part 3 (upload dependencies into Azure Storage account)

1. Login on to the computer which is connected to offline environment and also contains all the artifacts transferred in Part 2.
2. Launch PowerShell.
3. Run following command to change the directory.

    `cd ato-toolkit\automation\zero-trust-architecture-offline`

4. Run following command to connect to Azure Subscription. Change the -Environment parameter as needed.

    `Login-AzAccount -Environment AzureUSGovernment`

5. Run following command to create new storage account (or use if already exists) and upload all required artifacts into it. These artifacts will be used in the next steps to complete the deployment. Change the -ResourcePrefix and -Region parameters as needed. -ResourcePrefix is used to identify the ResourceGroup and Storage Account being created, use something that will avoid conflict with existing ones.

    `.\scripts\upload.ps1 -ResourcePrefix "testDeployment02" -Region "usgovarizona"`

> [!IMPORTANT]
> Script will output url of the artifact location, please note this for use in the next steps. I.e. 'https://testdeployment02artifacts.blob.core.usgovcloudapi.net/artifacts'. This is anonymous access storage container to enable seamless access during Custom Scripts Extensions execution in the Virtual Machines. DO NOT host sensitive data into it and DELETE it after successful deployment.

## Part 4 (deployment)

By now you have executed all required steps to prepare dependencies and artifacts required for this deployment. In this final part, executes instructions to complete the deployment.

### Review and update [run.config.json](run.config.json)

1. Login on to the computer which is connected to offline environment and also contains all the artifacts transferred in Part 2. Ignore this and skip to #8 if using the same computer and session as in Part 3.
2. Open the '.\run.config.json' in your favorite editor.
3. Update the value of 'parameters.artifact-storage-account-uri' with artifact url from previous step.
4. Review rest of the parameters carefully and make edits as necessary.

### Initiate deployment

1. Launch PowerShell.
2. Run following command to change the directory.

    `cd ato-toolkit\automation\zero-trust-architecture-offline`

3. Run following command to connect to Azure Subscription. Change the -Environment parameter as needed.

    `Login-AzAccount -Environment AzureUSGovernment`

4. Run following command to connect to Azure Subscription. Change the -Environment parameter as needed.

    `.\run.ps1`

5. Deployment is started which can be tracked in PowerShell window or in Azure Portal for progress and completion status.

## Connect to environment

1. From Azure portal, search for key vault with name "\*-sharedsvcs-kv" and configure it to allow access from specific network or from internet via firewall. [More info](https://docs.microsoft.com/en-us/azure/key-vault/general/network-security)
    * This is required to retrieve JumpBox VM password from the key vault secrets. [More info](https://docs.microsoft.com/en-us/azure/key-vault/secrets/about-secrets)

    > [!IMPORTANT]
    > Do not forget to revert the changes back after retrieving the password to lock down key vault to intended networks only.

2. From Azure portal, search for Azure Firewall name "\*-sharedsvcs-az-fw". Firewall is pre-configured with rule to allow access to JumpBox VM. Use firewall's public ip to connect to JumpBox VM to gain access to the environment. Default admin user name, unless changed during blueprint assignment, is 'jb-admin-user' and password retrieved in previous step.
