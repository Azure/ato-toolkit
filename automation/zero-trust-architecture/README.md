# Instructions

Following are the instructions to deploy artifacts included in the package, they may include-
* Azure Policy and Policy Set assignments
* Azure RBAC assignments
* Resource Groups and Resources

### Prerequisites 
1. An Azure Subscription (this is where audit policies and deployments will be implemented against).
2. Owner level permissions on the management group and subscription. Keep ManagementGroupId or SubscriptionId handy.
4. All the files and sub directories in current directory.


## Method 1- Azure Blueprint

Use this method if Azure Blueprint engine **is available** in targeted Azure Cloud environment and is desired framework for managing policy assignments and resource deployments. More on Azure Blueprints can be found [here](https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/lifecycle).

In order to customize and assign Blueprint we first need to import it into Azure Subscription, follow these steps to do so.

### Import via Azure CloudShell

    > [!TIP]
    > Alternatively you can execute same steps via PowerShell shell (min version 7.0.0) installed on local computer by connecting to target Azure Cloud environment and Subscription context. [Learn how to](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1)

1. Open CloudShell in Azure Portal. [Learn how to](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)

2. Launch PowerShell in Azure CloudShell. [Learn how to](https://docs.microsoft.com/en-us/azure/cloud-shell/overview#choice-of-preferred-shell-experience)
    > [!NOTE]
    > If you don't have any storage mounted, Azure CloudShell requires an Azure file share to persist files. This will create a new storage account. Click "Create Storage".

4. Run following command to clone the Azure ato-toolkit repository to clouddrive.
    ```powershell
    git clone https://github.com/Azure/ato-toolkit.git $HOME/clouddrive
    ```  
    > [!TIP]
    > Run `dir $HOME/clouddrive` to verify content of directory.

4. Run following command to import artifacts as Blueprint and save it within the specified subscription or management group.

    ```powershell
    Import-AzBlueprintWithArtifact -Name "YourBlueprintName" -SubscriptionId "00000000-1111-0000-1111-000000000000" -InputPath "$HOME/clouddrive/ato-toolkit/automation/zero-trust-architecture/blueprint"
    ```
    > [!NOTE]
    > The input path must point to the folder where blueprint.json file is placed.

5. From Azure Portal, browse to Azure Blueprint service tab and select "Blueprint definitions". You can review newly imported Blueprint in there and follow instructions to edit, publish and assign blueprint. [Learn how to](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#edit-a-blueprint)

## Method 2- Azure PowerShell

Use this method if Azure Blueprint engine **is not available** in targeted Azure Cloud environment or is not a preferred framework for managing policy assignments and resource deployments. More on Azure PowerShell can be found [here](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1).

> [!WARNING]
> This is work in progress. Send feedback by creating issue.