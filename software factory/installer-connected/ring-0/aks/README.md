# Project C12 - Alpha
---
# Table of contents
* [Overview](#overview)
* [Target audience](#target-audience)
* [Terminology and conventions](#terminology-and-conventions)
* [Prerequisites](#prerequisites)
* [Getting started with C12](#getting-started)
* [Supported scenarios](#supported-scenarios)
---

> **Disclaimer: Project C12 is currently in an alpha phase. The code in this project should only be used for evaluation purposes. The code in this project should NOT be used in production environments.**

## Overview

Project C12 is work in progress towards a reference design and set of automation scripts for building a governed, enterprise-grade environment where line of business developers can be productive, while operating in
a well-governed and secure environment.

## Target audience 

Project C12 is being designed for **enteprise customers** that want to accelerate their path to an Azure-based container-hosting platform. It assumes:
* **Microsoft Azure** as the cloud provider of choice  
* **Azure Active Directory** as the identity provider
* **GitHub Enterprise Cloud** as the software development platform (this requires a license)
* **Kubernetes** as the target container orchestrator/hosting platform (currently the code in this project targets AKS)
* **DevOps** as the prevailing set of practices/model for LOB application developers
* **Enterprise-grade requirements** for governance and compliance to one or more control sets

### Our definition of Enterprise-grade

We uphold the following principles as the basis of our definition of "Enterprise-grade":
* Assume zero trust configuration
* Assume no connectivity unless explicitly allowed by policy
* Every configuration is policy-driven
* All configuration and code changes are subject to PR review/approval and generate attestation and lineage logs
* Assume dependency on on-premises application services
* Assume diversity of application platforms (both Linux and Windows applications)
* Assume multi-tenant environment (Soft Tenancy Namespaces) for most applications
  * Some applications require cluster-level isolation
* High level of observability across all components
* Separation of concerns

#### Roles and responsibilities

* Application developers (**AppDevs**). Application developers are responsible for developing software in service to the business. They are organized into application portfolio teams. Some are providing shared services to enable other developers, while some are targeting a set of line of business applications. All code developed by AppDevs is subject to a set of requirements and quality gates upholding coding standards, compliance, attestation, and release management processes. 
* Application owners (**AOs**). Application owners are responsible for prioritizing features, and aligning application milestones/releases with business goals and milestones. 
* Application portfolio operators/SRE (**APOs**). APOs have skills similar to AppDevs but their mission is intended to leverage a relatively deep understanding of the code base, to develop a deep expertise on troubleshooting, observability standards, operations (scaling and dependency management) and break fix processes (to react to application downtime events). AppDevs and APOs work very closely together to improve availability, scalability and performance of the applications. 
* Infrastructure owners (**IOs**). Infrastructure owners are responsible for the architecture, connectivity and functionality of services deployed and maintained in the company IT department (this encompasses Public Cloud hosted services, and on-prem/private cloud services). They are concerned with ensuring the infrastructure is cost effective and provides the appropriate “abilities” such as connectivity, data retention, business continuity features etc. 
* Infrastructure operators/SRE (**IOps**). Infrastructure operators are concerned with the health of the container hosting infrastructure and dependent services. They ensure the platform offers appropriate capacity and availability to AppDevs and APOs. 
* Policy/security owners (**PSOs**). The IT staff playing this role have deep security and/or regulation compliance expertise. Their accountability rests in the definition and encoding of company policies that protect the security and regulatory compliance of the company employees, its assets, and those of the company’s customers. It is the company’s goal to encode and automate as many of these policies as possible, and to enforce very high standards around their versioning, attestation, and release management. 

## Terminology and conventions

TODO

## Prerequisites
C12 will assume the user has existing subscriptions to:
* **Azure**. To create a subscription, please see [here](https://azure.microsoft.com/en-us/)
* **GitHub Enteprise Cloud**. To create a subscription, please see [here](https://github.com/enterprise)

The following are software prerequisites for installing C12:
**NOTE: C12 has been tested using the versions of the prerequisite tools below specified in brackets. For instance, Terraform v0.12.24 is known to work. Please be warned that later versions of these tools might introduce breqaking changes.**

* **Git** for source control. To install Git, download and follow the instructions [here](https://git-scm.com/downloads). **NOTE:** Please make sure you configure git with your email contact by running `git config --global user.email "<your email>"`.
* **Kubectl** for managing the Kubernetes clusters. To install kubectl, download and follow the instructions [here] (https://kubernetes.io/docs/tasks/tools/install-kubectl) (v1.18.2)
* **Docker** for packaging containers. To install Docker, download and follow the instructions [here] (https://docs.docker.com/engine/install/). (v19.03.12)
* **Azure CLI**. To install the Azure CLI, download and follow the instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) (v2.10.0)
* **Helm**. To install Helm, download and follow the instructions [here](https://helm.sh/docs/intro/install/) (v3.2.1)
* **Terraform**. To install Terraform, download and follow the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) (v0.12.24)
* **Bash command line interpreter** or WSL on Windows. To install WSL, download and follow instructions [here](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
* **jq**. To install jq, download and follow instructions [here](https://stedolan.github.io/jq/download/)
* **Optional IDE**. While not necessary, it is recommended to use an IDE like Visual Studio Code to clone and navigate Project C12 runtime's repo. To install Visual Studio Code, download and follow the instructions [here](https://code.visualstudio.com/Download)


The following parameters will be needed by the C12 automation scripts:

* **Azure Subscription ID**. To find your Azure subscription ID, follow the instructions [here](https://docs.microsoft.com/en-us/archive/blogs/mschray/getting-your-azure-subscription-guid-new-portal)
* **Azure Location ID**. This is the Azure region you wish to use for C12. For example "northeurope" for the "North Europe" region. For a list of available regions, and region IDs 
type `az account list-locations -o table`. 
**NOTE**: C12 creates a private AKS cluster which is not supported in all Azure regions yet. For a list of currently supported regions, please see [here](https://docs.microsoft.com/en-us/azure/aks/private-clusters)
* **Company prefix**. This is an abbreviation for your company name. It will be used to name test environment resources and repos. Something like "contoso" would work ("Contoso Inc." would not work. Please use a short name and follow guidance [here](https://docs.microsoft.com/en-us/azure/devops/organizations/settings/naming-restrictions?view=azure-devops)).  
* **Github access token** and **Github access token user name**. For instructions on how to create the Github access token and provide these parameters, see the security [README.md](/docs/Security/README.md). 
* **GitHub organization**. The GitHub organization for your GitHub Enterprise Cloud subscription. This is the suffix <myorg> in the org URL: https://github.com/<myorg>

**Last but not least**, the user installing C12 needs to:

* Be member of the docker group. Run the following command to add the current user to this group: ```sudo gpasswd -a $USER docker``` Logoff to your session and log back in. With the new group permissions you should now be able to run `docker run hello-world` (without sudo) succesfully.
* Have the Azure CLI logged on to their Azure subscription.
* Have sufficient rights to create repos in the GitHub Enterprise Organization and have an SSH key configured. For instructions on how to configure the SSH key, see the security [README.md](/docs/Security/README.md). For more information on GitHub Enterprise access levels, see [here](https://help.github.com/en/github/setting-up-and-managing-organizations-and-teams/permission-levels-for-an-organization)
* Have Azure Active Directory configured, and sufficient rights to create groups and service principals for their tenant domain (currently this is via membership to the Global administrator role).

## Getting started

To get started with Project C12, follow the following steps:

* **Cloning the Project C12 repo**. This will create your own copy of the C12 Runtime repository. This will allow you to download the automation and documentation
for offline use.
* **Configuring the project .ini file**. After cloning the C12 runtime repo, you will need to provide parameters to the automation provided. See the "Configuring the project .ini file" section below for details.
* **Creating the evaluation environment**. The `bootstrap.sh` script is the entry point for the automation that comes with Project C12. It will use your GitHub Enterprise subscription to 
create a number of code repos, it will setup a simple test environment on Azure, and configure all components and accounts for you. For more information on the automation steps, 
see the "Creating the evaluation environment" section below.

### Cloning the C12 repository
To clone the C12 repo: 
1. Use a browser to navigate to the repo home page [here](https://github.com/Azure/ato-toolkit)
2. Click on Clone (top right of the page) 

Alternatively, you can use `git.exe` from the command line to clone from the above URL. 

### Enable Azre Arc Support
> __[PREVIEW]__  
>
> Enabling will use Azure ARC's cluster Configuration Agent to manage C12's cluster state. 
>
> Please ensure you're Azure subscription has the Azure Arc Preview enabled and have the AZ-CLI Extention `k8sconfiguration` and helm 3 to their latest versions.

#### required step for C12 integration

* Enable feature flag in c12.ini file to true: `arc-support=true`
* Ensure you're machine has the latest version of Azure CLI
  * See: [Here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* Ensure you're machine has the latest version of Azure CLI Extention `k8sconfiguration`
  * Install: `az extension add --name k8sconfiguration`
  * Ensure latest version: `az extension update --name k8sconfiguration`
* Ensure you're machine has the latest version of Helm 3
  * See: [Here](https://helm.sh/docs/intro/install/)
* Ensure Arc Preview is enabled on Azure Subscription.
  * Enable: `az provider register --namespace Microsoft.Kubernetes`
  * Enable: `az provider register --namespace Microsoft.KubernetesConfiguration`
  * Verify: `az provider list | grep Microsoft.Kuberne`
* Ensure AKS cluster to be created in Azure Arc support azure location.
  * Supported Locations:
    * East US `eastus`
    * west Europe `westeurope`

### Configuring the project .ini file

Project C12 features a `bootstrap.sh` script to automate the onboarding process. This script expects to read a `.ini` file containining the necessary parameters to customize 
execution. For guidance on how to populate the `.ini` file, see the reference below:
```
[azure]
;[arc-support] [PREVIEW] See README for more info.
arc-support=false
;[location] ID of the location used for the C12 components
location=<location id>
;[subscription] ID of the subscription used for the C12 components
subscription=<subscription id>

[c12]
;[prefix] Prefix to use for names within the C12 deployments
prefix=<prefix>

[c12:bootstrap]
;[phase] Phase of C12 bootstrap - do not manually edit
phase=bootstrap-config-generated

[github]
;[access-token-username] GitHub username that was used to generate the access-token
access-token-username=<github username>
;[access-token] GitHub Personal Access Token Used to manage the GitHub Organisation 
access-token=<access token>
;[org] GitHub org to use for C12 repos and co-ordination
org=<github org>
```

For the most up to date configuration settings for the `.ini` file, run `bootstrap.sh --generate-config-example`. 
For details on the``botstrap.sh` options and configuration, please see [here](./automation/aks/src/runtime/bootstrap/README.md).

### Creating the evaluation environment
After configuring the `.ini` with your parameters, and having taken care of all prerequisites, you can go ahead and launch the installation script `./automation/aks/src/runtime/bootstrap/bootstrap.sh`. 
#### User groups, service principals and access rights
C12 creates a set of AAD user groups,  service principals, GitHub teams and Kubernetes role and bindings to allow access to both users and automation (CI). All created entities are prefixed with the <prefix> parameter configured in the `.ini` file.
See the Security [README.md](/automation/aks/docs/Security/README.md) file for more information on the starting configuration created by the bootstrap process, as well as guidance on how to populate
 the AAD groups/ GitHub teams.

#### The core set of C12 repositories
C12 creates a set of starting repositories that will facilitale the management of different aspects of the environment. The following is an outline of each repo, its purpose and links to more information on using 
and customizing it.
| **Repo**        | **Who is it for?**           | **Purpose** |
| :------------- |:-------------|:-------------|
| <prefix>-application-management      | **<Multiple roles>** | This repo is used to add, configure, and deploy applications. 
| <prefix>-archetype-management | **IOs**?? TODO:Validate | This is the repo where application archetypes are defined. |
| <prefix>-cluster-management      | **IOs**?? TODO:Validate | This repo is used to add clusters to the C12 environment.
| <prefix>-cluster-state      | **<Not for direct user editing. Flux use only>** | This repo is used by the Flux instance associated to each C12 cluster to pull configuration data. 
| <prefix>-sample-nodejs-src      | **AppDevs** | This is the <Application> source code repo. It gets created for every application onboarded to C12 (with a name of <prefix>-<application name>-src) and is used by developers to source control and build application code. The bootstrap automation create a repo for this called <prefix>-sample-nodejs-src. |
| <prefix>-sample-nodejs-state      | **<Not for direct user editing. Flux use only>** | This is the <Application> state repo. It gets created for every application onboarded to C12 (with a name of <prefix>-<application name>-state). The bootstrap automation create a repo for this called <prefix>-sample-nodejs-state. This repo is used by the Flux instance associated to each application to pull configuration data |

#### The basic Azure evaluation setup
The generated test environment for project C12 consists on one resource group called `<Company prefix>-c12-rg`. The resource group contains:
| **Resource**        | **Type**           | **Notes** |
| :------------- |:-------------|:-------------|
| <prefix>-aks      | Kubernetes service | This is the test AKS cluster that will be used to host applications. It is configured as a private cluster|
| <prefix>-network      | Virtual network | This is the VNET shared by all C12 resources|
| <prefix>-network-jumphost      | Virtual Machine | This is a Linux Ubuntu VM that will be used as a jumpbox for accessing C12 resources|
| <prefix>-network-jumphost-nic      | Network interface | |
| <prefix>-network-jumphost-nsg      | Network security group | |
| <prefix>-network-jumphost-os      | Disk | |
| <prefix>-network-jumphost-pip      | Public IP address | |
| <prefix>-network-worker      | Network security group | |
| <prefix>aksacr      | Container registry | This is the ACR instance that will be used to store Production container images|
| <prefix>aksdevacr      | Container registry | This is the ACR instance that will be used for dev/test|
| <prefix>terraformstate      | Storage account | This is the storage account used by Terraform|

#### The sample application
The C12 bootstrap automation (`bootstrap.sh`) includes a sample node.js application already onboarded in the Application-Management repo with the associated repos (ApplicationSample-Src and ApplicationSample-State). For more information
on the sample application see the README.md file [here](/automation/aks/src/sample-apps/nodejs/README.md). 

### Exploring the evaluation environment
TODO

### Troubleshooting `bootstrap.sh`
TODO

##Supported scenarios
### Adding an existing AKS cluster 
### Adding a governed application
### Deploying a governed application to production


