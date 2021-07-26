# Instructions

Follow these instructions to deploy Azure Virtual Machines in an offline (disconnected from from internet, environment such as Azure Stack and other private Azure configurations). If deploying to an environment which does have internet connectivity, refer the [instructions for online version](../README.md).

This automation has dependencies for an external package that needs to be downloaded from the internet, to enable that instructions which are divided into 4 parts. Part 1- downloads and packages all the dependencies, Part 2- outlines how to securely transfer all the automation code, documentation and downloaded dependencies into offline environment. Part 3- uploads all the dependencies into Azure storage account which is accessible from offline (disconnected from public internet) environment. This is required to make sure automation can access these artifacts at the time of deployment. And lastly Part 4- initiate deployment. 

Following instructions guide each one of these parts in detail.

## Part-1 (download and package dependencies)

Run these steps from an internet connected computer.

### Windows

For Windows bases OSes the dependencies include PowerSTIG and other DSC configurations. For complete list of PowerShell modules being downloaded, refer '.\scripts\RequiredModules.ps1'.

#### Prerequisites for Windows

1. Windows Server 2019 or Windows 10 with Powershell 5.1 installed. To set one up easily in Azure [follow these steps](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal).
2. Git installed. [how to](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
3. Outbound Internet connectivity to 'www.powershellgallery.com'.

#### Instructions for Windows dependency preparation

1. Open an elevated (Admin) PowerShell terminal and execute following commands.

    `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

2. Run following command to clone Azure ato-toolkit repository to your local working directory.

    `git clone azure-ecosystem@vs-ssh.visualstudio.com:v3/azure-ecosystem/project-chairlift/project-chairlift`    $CHANGE THIS BEFORE RELEASE$

    > [!TIP]
    > Run `dir` to verify content of directory.

3. Run following command to change the directory.

    `cd project-chairlift\windows`    $CHANGE THIS BEFORE RELEASE$

4. Run following command to download all the required PowerShell module dependencies.

    `.\scripts\InstallModules.ps1`

5. Run following command to package all the dependencies.

    `.\scripts\build-offline.ps1`

## Part 2 (transfer automation code/scripts, documentation and downloaded dependencies into offline environment)

By now you would have successfully executed Part 1. All the downloaded dependencies are placed in '.\scripts\dependencies' folder.

Now, using your preferred method of data transfer, transfer folder 'windows' and all of its content (including all code/scripts, documentation and downloaded packages files) onto a computer connected to offline environment. Rest of the steps will be executed from within offline environment.

### Prerequisites for computer in offline environment

1. Windows Server 2019 or Windows 10 with Powershell 5.1 installed. To set one up easily in Azure [follow these steps](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-portal).
2. PowerShell installed. [how to](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7).
3. Azure Powershell module installed. [how to](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-4.4.0).

## Part 3 (upload dependencies into Azure Storage account)

1. Login on to the computer which is connected to offline environment and also contains all the artifacts transferred in Part 2.
2. Launch PowerShell.
3. Run following command to change the directory.

    `cd project-chairlift\windows`    $CHANGE THIS BEFORE RELEASE$

4. Run following command to connect to Azure Subscription. Change the -Environment parameter as needed.

    ```azurepowershell
    Import-Module Az
    Login-AzAccount -Environment AzureUSGovernment
    ```

    > [!TIP]
    > Run `Get-AzContext` to make sure default subscription is set as expected. Run `Set-AzContext -SubscriptionId "00000000-1111-0000-1111-000000000000"` to set default subscription context.

5. Run following command to create new storage account (or use if already exists) and upload all required artifacts into it. These artifacts will be used in the next steps to complete the deployment. Change the -ResourcePrefix and -Region parameters as needed. -ResourcePrefix is used to identify the ResourceGroup and Storage Account being created, use something that will avoid conflict with existing ones and still be able to form valid storage account name. Use all small string of 3 to 5 chars as an example.

    `.\scripts\upload-offline.ps1 -ResourcePrefix "aqswdefr" -Region "usgovarizona"`

> [!IMPORTANT]
> Script will output Azure Portal url and Storage Container, please note these for use in the next steps. Container I.e. 'https://testdeployment02artifacts.blob.core.usgovcloudapi.net/artifacts' is anonymous read access storage container to enable seamless access during Custom Scripts Extensions execution in the Virtual Machines. DO NOT host sensitive data into it and DELETE it after successful deployment.

## Part 4 (deployment)

1. Open Azure Portal url resulted in Part 3 and follow Azure Portal screen instructions to complete the deployment.

2. TODO: PowerShell or CLI deployment commands.

## Connect to environment

1. TODO
