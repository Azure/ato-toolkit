DSOP on Azure

Framework includes:
1. What is DSOP on Azure
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
  * OpenShift: [manual steps](https://docs.openshift.com/container-platform/4.5/installing/installing_azure/installing-azure-default.html) or [automated steps](https://github.com/Azure/ato-toolkit/tree/master/automation/dsop/installer-connected/ring-0/openshift/ocp3.11)
  
4. How to get support for DSOP on Azure
