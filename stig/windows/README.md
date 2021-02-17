# Deploy Azure Virtual Machine (Windows) and apply STIG

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fato-toolkit%2Fmaster%2Fstig%2Fwindows%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fato-toolkit%2Fmaster%2Fstig%2Fwindows%2FcreateUiDefinition.json)
[![Deploy To Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fato-toolkit%2Fmaster%2Fstig%2Fwindows%2Fazuredeploy.json/createUIDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fato-toolkit%2Fmaster%2Fstig%2Fwindows%2FcreateUiDefinition.json)

Use this template to deploy Azure Virtual Machine with select Windows 2019 Operating Systems. Template executes automation provided by [PowerSTIG](https://github.com/microsoft/PowerStig) via [Azure Custom Scripts Extension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows) to apply [STIG](https://public.cyber.mil/stigs/).

If you're new to Azure virtual machines, see:

- [Azure Virtual Machines](https://azure.microsoft.com/services/virtual-machines/)
- [Azure Windows Virtual Machines documentation](https://docs.microsoft.com/azure/virtual-machines/windows/)
- [Template reference](https://docs.microsoft.com/azure/templates/microsoft.compute/allversions)
- [Quickstart templates](https://azure.microsoft.com/resources/templates/?resourceType=Microsoft.Compute&pageNumber=1&sort=Popular)

If you're new to template deployment, see:

- [Azure Resource Manager documentation](https://docs.microsoft.com/azure/azure-resource-manager/)
- [Quickstart: Create a Windows virtual machine using an ARM template](https://docs.microsoft.com/azure/virtual-machines/windows/quick-create-template)