# Hydration

## Overview

Hydration is the initial script to run that will setup your installation environment to deploy the DSOP. It expects a clean vm in the environment running `Windows Server 2019`. This hydration script:
1. installs az cli
2. installs az copy
3. attempts to register the az cloud (this does not currently work because of a [bug in az cli](https://github.com/Azure/azure-cli/issues/14653))
4. does an interactive login with the installer
5. creates a resource group and places in keyvault in it
6. creates a service principal with a password by default
7. stores the password in keyvault
8. assigns the service principal as contributor
9. logs into az with the service principal

## Running

1. Create a Resource Group thusly:
   ```powershell
   az group create -n <resourcegroup> -l <location>
   ```
2. The Windows Server 2019 VM can be created using the above created Resource Group:
   ```powershell
   az vm create -g <resourcegroup> -n <vm_name> --image Win2019Datacenter --admin-username azureuser
   ```
3. Create a .zip of the `CloudFit-DSOP` repository and copy the .zip file to Azure Blob Storage (accessible by the VM)
4. Generate a Shared Access Signature token for the .zip file from Azure Blob Storage
5. RDP into the VM using the created username and password
6. Download the .zip of the `Cloudfit-DSOP` repository with the following command in Command Prompt:
   ```
   bitsadmin /TRANSFER dsop-transfer "<uri-from-blob-storage>" "C:\Users\azureuser\Desktop\cloudfit-dsop.zip"
   ```
7. Extract the contents of `C:\Users\azureuser\Desktop\cloudfit-dsop.zip`
8. Create a folder at `C:\Users\azureuser\Desktop\dsop`
9. Move the contents of `C:\Users\azureuser\Desktop\cloudfit-dsop.zip` to `C:\Users\azureuser\Desktop\dsop\`
10. To begin hydration:
    1. Open `pwsh.lnk`
    2. Navigate to `C:\Users\azureuser\Desktop\dsop\`
    3. Open the `deployment.vars.jsonc` file. This file is baseline for all variables that need to be provided. It is self documented so please look through it carefully and adjust. 
    Note: The specific variables that ought to be changed are as follows:
        - tenantId
        - subscriptionId
        - location
        - azCliRootCert
        - cloudName
        - servicePrincipleName
        - spCertName
        - spResourceGroup
        - spKeyvault
    4. Run the following command to start hydration
    ```powershell
    ./hydration.ps1
    ```
    Note: You will need to login to the Azure portal when prompted
