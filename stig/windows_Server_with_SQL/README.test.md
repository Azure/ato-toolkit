# Instructions

Follow these instructions to upload deployment templates, and all relevant scripts and dependency files into your Azure storage account, and generate Azure portal deployment url for local testing.

1. Open PowerShell terminal or use Azure CloudShell, and execute following command to clone repository to your local working directory.

    `git clone azure-ecosystem@vs-ssh.visualstudio.com:v3/azure-ecosystem/project-chairlift/project-chairlift`

2. Run following command to change the directory.

    `cd project-chairlift\windows`

3. Run following command to upload templates and scripts into Azure storage account. Set appropriate subscription context by running `Set-AzContext Set-AzContext -Tenant <TENANT ID> -SubscriptionId <SUBSCRIPTION>`. Resource group and Azure Storage account are prerequisites for the command, and command will fail if don't exists.

    ```azurepowershell
    Import-Module Az
    Login-AzAccount -Environment AzureCloud
    .\publish-to-blob.ps1 -resourceGroupName <RESOURCE GROUP NAME> -storageAccountName <STORAGE ACCOUNT NAME>
    ```

> [!IMPORTANT]
> Script will output Azure Portal url and Storage Container, please note these for use in the next steps. Container is anonymous read access storage container to enable seamless access during Custom Scripts Extensions execution in the Virtual Machines. DO NOT host sensitive data into it and DELETE it after successful deployment.
