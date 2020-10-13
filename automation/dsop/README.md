# DSOP on Azure

Framework includes:
1. What is DSOP on Azure
* Allows you to install in a singular way, regardless of unique tool permissions
2. Architecture of DSOP on Azure
3. How to use DSOP on Azure
* Go to Azure Portal of choice (e.g. Azure Gov)
* Open your Azure Cloud Shell
* Clone this GitHub repo into your Azure Cloud Drive using the following command:
```
git clone https://github.com/azure/ato-toolkit.git
```
* Create K8 cluster
  * AKS:
  ```
  az aks create --resource-group my-rg --name mydemoAKSCluster --node-count 5 --enable-addons monitoring --generate-ssh-keys --vm-set-type AvailabilitySet
  ```
  * OpenShift: [manual steps](https://docs.openshift.com/container-platform/4.5/installing/installing_azure/installing-azure-default.html) or [automated instructions](https://github.com/Azure/ato-toolkit/tree/master/automation/dsop/installer-connected/ring-0/openshift/ocp3.11)
* Select the tools you want to install, follow either manual or automated instructions

|Ring|Application|Manual|Automated|Disconnected Notes
|---|---|---|---|---
||Hydration|N/A|[instructions](./hydration.md)|This prepares the deployment vm
|0|OCP 3.11|[manual steps](https://docs.openshift.com/container-platform/4.5/installing/installing_azure/installing-azure-default.html)|[instructions](./ring-0/ocp-3.11/instructions.md)|Check instructions and [download VHD](https://contest.blob.core.usgovcloudapi.net/vhdocp/bravo-registry-osDisk.vhd?sv=2019-02-02&st=2020-09-25T12%3A31%3A59Z&se=2020-10-07T12%3A31%3A00Z&sr=b&sp=r&sig=zzQiGcTvQkl8nCFro%2FPn29JlTPf9NMr7Ye0jq9CU404%3D) to carry in. Also need the [RHEL image](https://thesearemyfilesthankyou.blob.core.windows.net/deploy/rhelbase77.vhd.zip?sv=2019-10-10&st=2020-09-15T13%3A09%3A17Z&se=2020-10-16T13%3A09%3A00Z&sr=b&sp=r&sig=7la8PQ6KYeu%2BAbg4SqFvJtL%2FHe0NwHdSzQaflRdRkVM%3D) if the marketplace doesn't have it.
|0|OCPBastionPorterInstall|N/A|[instructions](./tools/docs/OcpBastionPorterInstaller.md)|This prepare the OCP Bastion by installing the Porter Binaries
|0|OpenEBS|N/A|[instructions](./ring-0/openebs/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/openebs.tgz?sv=2019-02-02&st=2020-09-18T17%3A08%3A47Z&se=2020-10-19T17%3A08%3A00Z&sr=b&sp=r&sig=P3yBPPKcEYit%2Fl0jgEz93CnYvmCXnQ0kePU6Ae3GYeM%3D)
|1|Elastic|[manual steps](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/elastic.elasticsearch?tab=Overview)|[instructions](./ring-1/elastic/instructions.md)|VM based deployment
|1|Logstash|[manual steps](https://www.elastic.co/guide/en/logstash/current/getting-started-with-logstash.html)|[instructions](./ring-1/logstash/instructions.md)|VM based deployment
|1|Kibana|[manual steps](https://www.elastic.co/guide/en/kibana/current/getting-started.html)|[instructions](./ring-1/kibana/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/end-to-end/kibana.zip?sv=2019-02-02&st=2020-09-25T12%3A30%3A42Z&se=2020-10-07T12%3A30%3A00Z&sr=b&sp=r&sig=9ucRIM8irMhleSam0HCVnGrbUlvgXpmfJ9FEI2%2B02S4%3D)
|2|Nessus|[manual steps](https://docs.tenable.com/integrations/Microsoft/Azure/Content/welcome.htm)|[instructions](./ring-2/nessus/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/nessus.tgz?sv=2019-02-02&st=2020-09-18T17%3A09%3A57Z&se=2020-10-10T17%3A09%3A00Z&sr=b&sp=r&sig=uMpzmcjVBG9YLcr8TvfKtk8ci0b6UZM9uwkC2HTNrCg%3D)
|2|Fortify|[manual steps](https://marketplace.visualstudio.com/items?itemName=fortifyvsts.hpe-security-fortify-vsts)|[instructions](./ring-2/fortify/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/fortifyssc.tgz?sv=2019-02-02&st=2020-09-18T17%3A10%3A56Z&se=2020-10-10T17%3A10%3A00Z&sr=b&sp=r&sig=Z2%2FElANW7fDg%2FC3VOiuO%2BSQrmEu%2FFxLw6%2F2J7JbMzrA%3D)
|2|Twistlock|[manual steps](https://azuremarketplace.microsoft.com/en-in/marketplace/apps/twistlock.twistlock?tab=Overview)|[instructions](./ring-2/twistlock/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/twistlock.tgz?sv=2019-10-10&st=2020-09-15T13%3A54%3A15Z&se=2020-10-16T13%3A54%3A00Z&sr=b&sp=r&sig=0PFyzrHbZJMflHo26Vmo5BjtvoPu4SzXQahu%2FOn0w1I%3D)
|2|Anchore|[manual steps](https://azuremarketplace.microsoft.com/en-in/marketplace/apps/anchore.anchore-engine?tab=Overview)|[instructions](./ring-2/anchore/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/anchore.tgz?sv=2019-10-10&st=2020-09-15T13%3A54%3A51Z&se=2020-10-16T13%3A54%3A00Z&sr=b&sp=r&sig=YGDN1iwLTWmMIRxgiMxCTvWeoMkFvC7wEcdFBm01sW4%3D) as well as the corresponding postgres porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/anchore-postgres.tgz?sv=2019-02-02&st=2020-09-18T17%3A16%3A13Z&se=2020-10-10T17%3A16%3A00Z&sr=b&sp=r&sig=3o0onPFRsF2IzGkQmy0n%2BOjFRTt510HNi4O5uAkvpQk%3D)
|2|Sonarqube|[manual steps](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-azure-devops/)|[instructions](./ring-2/anchore/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/sonarqube.tgz?sv=2019-02-02&st=2020-09-25T11%3A57%3A07Z&se=2020-10-07T11%3A57%3A00Z&sr=b&sp=r&sig=%2F3Is%2FC5NUbW9u8QOgsPV%2BT%2FfcgTZ0IIf4b3B2bEJFNU%3D)
|3|Jira|[manual steps](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/atlassian.jira-data-center)|[instructions](./ring-3/jira/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/jira.tgz?sv=2019-02-02&st=2020-09-25T11%3A17%3A51Z&se=2020-10-07T11%3A17%3A00Z&sr=b&sp=r&sig=q7ZmlObD3wlUo3it16kRn%2FkkLoVXlq00LGNIoFQLBZ8%3D)
|3|Mattermost|[manual steps](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/bitnami.mattermost?tab=Overview)|[instructions](./ring-3/mattermost/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/mattermost.tgz?sv=2019-02-02&st=2020-09-25T12%3A22%3A48Z&se=2020-10-07T12%3A22%3A00Z&sr=b&sp=r&sig=MMOi3oL9XTzxH8SXGsp%2FCcVhOHw%2B2L7Yfbc2V3s4OME%3D)
|3|Confluence|[manual steps](https://confluence.atlassian.com/doc/getting-started-with-confluence-data-center-on-azure-937176452.html)|[instructions](./ring-3/confluence/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/confluence.tgz?sv=2019-02-02&st=2020-09-25T11%3A16%3A23Z&se=2020-10-07T11%3A16%3A00Z&sr=b&sp=r&sig=YkhsReHPH0vX6c%2Frz%2FyR0updLpnugMLAlpuhRijepYk%3D)
|5|CFS|[manual steps](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/cloudfitsoftware.cloudfit-velocity?tab=Overview)|[instructions](./ring-5/cfs/instructions.md)|Uses porter CNAB bundle - [download here](https://contest.blob.core.usgovcloudapi.net/vhdocp/cfs.tgz?sv=2019-02-02&st=2020-09-25T11%3A15%3A13Z&se=2020-10-12T11%3A15%3A00Z&sr=b&sp=r&sig=W%2FKBADdGoFFW7fRHT7U8R%2F4jj4TiGSfi0IJD51ALOPY%3D)

4. How to get support for DSOP on Azure
