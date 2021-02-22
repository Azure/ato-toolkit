# Creating the Github personal access token for the C12 .ini file
As a prerequisite to running bootstrap.sh, you will need to populate the .ini file with a number of parameters.
This guide will help you configure the `access-token` and `access-token-username`.
1. First log in to your organization on github by using a browser to navigate to https://github.com/<myorg> (where <myorg> is the name of your Github org). Take a note of your <username> as you will need this value to configure the
.ini file under the [github] section: access-token-username=<username> 
2. Open the settings page by clicking on your user icon (top-right of the page) and selecting **Settings**
3. Under the **Personal settings** options, select **Developer settings**
4. Under the **Github Apps** options, select **Personal access tokens**
5. Click on the **Generate new token** button and authenticate
6. In the **New personal access token** page, enter a note for the token (something like "Token for running C12 bootstrap automation").
7. In the **Selected scopes** section, tick the check box selecting the following access rights:
     * repo
     * admin:org
     * admin:repo_hook
     * delete_repo
     * admin:enterprise
8. Press the **Generate token** button
9. In the **Personal access tokens** page, you will now see the token, please select it and copy it. This will be <your token> you will need to configure in the .ini file under the [github] section: access=token=<your token>.
Before leaving this page, press the **Enable SSO** button, and the **Authorize** button in the section that appears.

# Configuring the GitHub SSH key
As a prerequisite to running bootstrap.sh, you will need to have SSH configured for your account. Before proceeding, make sure you have a set of SSH keys already created following the guide [here](https://www.ssh.com/ssh/keygen).
The following steps will help you configure the SSH key for bootstrap.sh to use for access to the created GitHub repos.
1. First log in to your organization on github by using a browser to navigate to https://github.com/<myorg> (where <myorg> is the name of your Github org).  
2. Open the settings page by clicking on your user icon (top-right of the page) and selecting **Settings**
3. Under the **Personal settings** options, select **SSH and GPG keys**
4. Press the **New SSH key** button
5. Enter a **title** ("C12 key" for example), and copy/paste the public key (usually under `/.ssh/id_rsa.pub`) into the **key** box. 
6. Press the **Enable SSO** button, and the **Authorize** button in the section that appears

# Bootstrap-created configuration for user/identity management
This is meant to be a comprehensive list of all the service principals, AAD groups, Github teams/key sets, and Kubernetes roles needed to deploy and operate the C12 Solution.

## AAD Users, Groups, Service Principals
| **Name**        | **Type**           | **Use** | **Instances** | **Provisioning time** |
| :-------------|:-------------|:-------------|:-------------|:-------------|
|$prefix-aks | service principal | Used by AKS to provision resources for the Kubernetes Cluster | one | bootstrap |
|$prefix-sample-app-nodejs-dev |group|Application developers for sample-app-nodejs|one|bootstrap|
|$prefix-sample-app-nodejs-owner |group|Application owners for sample-app-nodejs that can approve PRs to the sample-app-nodejs-src repo|one|bootstrap|
|$prefix-application-management-owner |group|People who can approve changes in the application-management repo|one|bootstrap|
|$prefix-c12-policy-security-owners |group|This is the AAD group created for Security/Policy owners.|one|bootstrap|
|$prefix-c12-infrastructure-break-glass |group|Breakglass group for Kubernetes that allows full control of a cluster|one|bootstrap|
|$prefix-c12-infrastructure-sre |group|AAD group for Kubernetes that allows day to day action to be performed on a cluster|one|bootstrap|
|$prefix-c12-sample-app-nodejs-sre |group|AAD group for Kubernetes that allows day to day action to be performed on the sample-app-nodejs namespaces|one|bootstrap|
|$prefix-c12-sample-app-nodejs-break-glass |group|Breakglass group for Kubernetes that allows full control of the sample-app-nodejs namespaces|one|bootstrap|
|$prefix-c12-sample-app-nodejs-read-only |group|Application developers for sample-app-nodejs that can view status of pods and deployments in Kubernetes|one|bootstrap|


## GitHub teams, access tokens and deploy keys
| **Name**        | **Type**           | **Repo** | **Use** | **Instances** | **Provisioning time** | **PUSH/PULL** |
| :------------- |:-------------|:-------------|:-------------|:-------------|:-------------|:-------------|
|$prefix-application-management-owner | team | application-management | People who can approve changes in the application-management repo | one | bootstrap ||
|$prefix-sample-app-nodejs-dev | team | exmaple-app-src |People create PRs in the sample-app-nodejs-src repo | one | bootstrap ||
|$prefix-sample-app-nodejs-owner| team | exmaple-app-src |People who can approve changes in the exmaple-app-src repo | one | bootstrap ||
|terraform ACCESS_TOKEN | Access Token | all | Used by terraform to create repos, teams and configure them. | one | before bootstrep | |


## C12 Kubernetes Role definitions
| **Name**        | **Type**           | **Use** | **Instances** |**Provisioning time** |
| :------------- |:-------------|:-------------|:-------------|:-------------|
||||||

## C12 Kubernetes Role bindings
| **Role**        | **Scope**           | **Group(s)** |
| :------------- |:-------------|:-------------|
||||

# Guidance on populating groups/teams
TODO




