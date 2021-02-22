# Kibana

**Estimated Time:**

- Smart Hands Preparation Time: 5 mins
- Deployment Time: 5 mins

## Prerequisites

* These instructions assume running in windows
* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) - included in install bits
* Latest version of [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7) - included in install bits

## Deployment (testing) Instructions

Running the deployment will connect to Azure using the cli, copy files to the bastion, and deploy into the kubernetes cluster.

1. Open `./tools/porter.deployment.vars.jsonc` in a text editor. Ensure the variables match those used with the OCP 3.11 deployment.
2. Open Powershell with the provided link.
2. Move in to the `./tools` directory.
3. From within the `.tools` directory execute the `./do-deploy.porter.ps1` file.
