# Instructions

Following are the instructions to deploy artifacts included in the package, they may include-

* Azure Policy and Policy-Set assignments. [More on Azure policies](https://docs.microsoft.com/en-us/azure/governance/policy/overview)

* Azure RBAC (Role Based Access Control) assignments. [More on Azure RBAC](https://docs.microsoft.com/en-us/azure/role-based-access-control/overview)

* Resource Groups and Resources. [Learn more](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/overview#terminology)

## Prerequisites

1. An active Azure or Azure Government subscription (this is where audit policies and other resources will be deployed).
2. Owner level permissions on the management group and subscription. Keep ManagementGroupId or SubscriptionId handy.
3. All the files and sub directories in current directory.

## Azure Blueprint

More on Azure Blueprint can be found [here](https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/lifecycle). In order to customize and assign blueprint we first need to import it into your Azure subscription, follow these steps to do so.

### Import via Azure CloudShell

> [!TIP]
> Alternatively you can execute same steps via PowerShell shell (min version 7.0.0) installed on local computer by connecting to target Azure Cloud environment and subscription context. [Learn how to](https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-3.6.1)

1. Open CloudShell in Azure Portal. [Learn how to](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)

2. Launch PowerShell in Azure CloudShell. [Learn how to](https://docs.microsoft.com/en-us/azure/cloud-shell/overview#choice-of-preferred-shell-experience)
    > [!NOTE]
    > If you don't have any storage mounted, Azure CloudShell requires an Azure file share to persist files. This will create a new storage account. Click "Create Storage".

3. Run the following command to clone the Azure ato-toolkit repository to clouddrive.
    ```powershell
    git clone https://github.com/Azure/ato-toolkit.git $HOME/clouddrive/ato-toolkit
    ```

    > [!TIP]
    > Run `dir $HOME/clouddrive` to verify content of directory.

4. Run the following commands to import the powershell module required to import the blueprint. Note: Commands may fail if module is already installed and imported.
    ```powershell
    Install-Module -Name Az.Blueprint
	Import-Module Az.Blueprint
    ```

5. Run the following command to import artifacts as blueprint and save it within the specified subscription or management group.
    ```powershell
    Import-AzBlueprintWithArtifact -Name "YourBlueprintName" -SubscriptionId "00000000-1111-0000-1111-000000000000" -InputPath "$HOME/clouddrive/ato-toolkit/zero trust architecture blueprint/zero-trust-architecture-v2/blueprint"
    ```

    > [!IMPORTANT]
    > Use -InputPath "$HOME/clouddrive/ato-toolkit/zero trust architecture blueprint/zero-trust-architecture-v2/blueprint_gov" for AzureUSGovernment environment.

    > [!NOTE]
    > The input path must point to the folder where blueprint.json file is placed.

6. From Azure Portal, browse to Azure Blueprint service tab and select "Blueprint definitions". You can review newly imported blueprint in there and follow instructions to edit, publish and assign blueprint. [Learn how to](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#edit-a-blueprint)

## Post blueprint assignment steps

Blueprint creates virtual networks, configures routing and firewall rules and enables audit and diagnostic. Spoke resource group is not ready for you to deploy your application workloads. To enable centralized management and connectivity, subnets created in Hub resource group can be utilized to host Jumpbox, Azure Bastion Host and or other shared management services such as Active Directory.

Please review all the Firewall and Network Security Group rules and make necessary customizations required to support your application workload.

If more than one Spokes are needed for additional applications. Re-assign the blueprint or update the assignment by providing following parameter values. 

* Deploy Hub: false
* Spoke Workload name: New name
* Virtual Network address prefix: New value that will not create conflict with existing address prefixes.

## Feedback

For more information, questions, or feedback please [contact us](https://aka.ms/zerotrust-blueprint-feedback).
