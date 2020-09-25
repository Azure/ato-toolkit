package com.microsoft.c12.asoallowedlocations

az_aso_api_group := "azure.microsoft.com"
alpha_v1 := "v1alpha1"

allowed_location_northeurope := "northeurope"
allowed_location_southeurope := "southeurope"
allowed_locations := [allowed_location_northeurope, allowed_location_southeurope]
disallowed_location := "wonderland"
disallowed_location_alt := "utopia"


apimgmt_kind_name :=  "APIMgmtAPI"
apimgmtapi_kind  := {"group": az_aso_api_group ,  "version": alpha_v1, "kind": apimgmt_kind_name }
apimgmt_obj := {
	"apiVersion": alpha_v1,
	"kind": apimgmt_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

apimservice_kind_name := "ApimService"
apimservice_kind  := {"group": az_aso_api_group ,"version": alpha_v1,"kind": apimservice_kind_name}
apimservice_obj := {
	"apiVersion": alpha_v1,
	"kind": apimservice_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

appinsights_kind_name := "AppInsights"
appinsights_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": appinsights_kind_name}
appinsights_obj := {
    "apiVersion": alpha_v1,
	"kind": appinsights_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}
azureloadbalancer_kind_name := "AzureLoadBalancer"
azureloadbalancer_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": azureloadbalancer_kind_name }
azureloadbalancer_obj := {
    "apiVersion": alpha_v1,
	"kind": azureloadbalancer_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

azurenetworkinterface_kind_name := "AzureNetworkInterface"
azurenetworkinterface_kind  := {"group": az_aso_api_group ,"version": alpha_v1,"kind": azurenetworkinterface_kind_name }
azurenetworkinterface_obj := {
    "apiVersion": alpha_v1,
	"kind": azurenetworkinterface_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

azurepublicipaddress_kind_name := "AzurePublicIPAddress"
azurepublicipaddress_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": azurepublicipaddress_kind_name }
azurepublicipaddress_obj := {
    "apiVersion": alpha_v1,
	"kind": azurepublicipaddress_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

azuresqldatabase_kind_name := "AzureSqlDatabase"
azuresqldatabase_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind":azuresqldatabase_kind_name }
azuresqldatabase_obj := {
    "apiVersion": alpha_v1,
	"kind": azuresqldatabase_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}
azuresqlfailovergroup_kind_name := "AzureSqlFailoverGroup"
azuresqlfailovergroup_kind  := {"group": az_aso_api_group ,"version": alpha_v1,"kind": azuresqlfailovergroup_kind_name }
azuresqlfailovergroup_obj := {
    "apiVersion": alpha_v1,
	"kind": azuresqlfailovergroup_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

azuresqlserver_kind_name := "AzureSqlServer"
azuresqlserver_kind := {"group": az_aso_api_group ,"version": alpha_v1,"kind": azuresqlserver_kind_name }
azuresqlserver_obj := {
    "apiVersion": alpha_v1,
	"kind": azuresqlserver_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}


azurevirtualmachineextension_kind_name := "AzureVirtualMachineExtension"
azurevirtualmachineextension_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": azurevirtualmachineextension_kind_name }
azurevirtualmachineextension_obj := {
    "apiVersion": alpha_v1,
	"kind": azurevirtualmachineextension_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

azurevirtualmachine_kind_name := "AzureVirtualMachine"
azurevirtualmachine_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": azurevirtualmachine_kind_name }
azurevirtualmachine_obj := {
    "apiVersion": alpha_v1,
	"kind": azurevirtualmachine_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

azurevmscaleset_kind_name :=  "AzureVMScaleSet"
azurevmscaleset_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": azurevmscaleset_kind_name }
azurevmscaleset_obj := {
    "apiVersion": alpha_v1,
	"kind": azurevmscaleset_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

blobcontainer_kind_name := "BlobContainer"
blobcontainer_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": blobcontainer_kind_name }
blobcontainer_obj := {
    "apiVersion": alpha_v1,
	"kind": blobcontainer_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

cosmosdb_kind_name := "CosmosDB"
cosmosdb_kind  := {"group": az_aso_api_group ,"version": alpha_v1,"kind": cosmosdb_kind_name }
cosmosdb_obj := {
    "apiVersion": alpha_v1,
	"kind": cosmosdb_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope,
        "locations" : [
            {
                "locationName" : allowed_location_northeurope
            },
            {
                "locationName" : allowed_location_southeurope
            }
        ]
	}
}


eventhubnamespace_kind_name := "EventhubNamespace"
eventhubnamespace_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": eventhubnamespace_kind_name }
eventhubnamespace_obj := {
    "apiVersion": alpha_v1,
	"kind": eventhubnamespace_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

eventhub_kind_name := "Eventhub"
eventhub_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": eventhub_kind_name }
eventhub_obj := {
    "apiVersion": alpha_v1,
	"kind": eventhub_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

keyvaultkey_kind_name := "KeyVaultKey"
keyvaultkey_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": keyvaultkey_kind_name }
keyvaultkey_obj := {
    "apiVersion": alpha_v1,
	"kind": keyvaultkey_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

keyvault_kind_name := "KeyVault"
keyvault_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": keyvault_kind_name }
keyvault_obj := {
    "apiVersion": alpha_v1,
	"kind": keyvault_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

mysqlserver_kind_name := "MySQLServer"
mysqlserver_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": mysqlserver_kind_name  }
mysqlserver_obj := {
    "apiVersion": alpha_v1,
	"kind": mysqlserver_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

postgresqlserver_kind_name := "PostgreSQLServer"
postgresqlserver_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": postgresqlserver_kind_name }
postgresqlserver_obj := {
    "apiVersion": alpha_v1,
	"kind": postgresqlserver_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

rediscache_kind_name := "RedisCache"
rediscache_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": rediscache_kind_name }
rediscache_obj := {
    "apiVersion": alpha_v1,
	"kind": rediscache_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

resourcegroup_kind_name := "ResourceGroup"
resourcegroup_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": resourcegroup_kind_name }
resourcegroup_obj := {
    "apiVersion": alpha_v1,
	"kind": resourcegroup_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

storageaccount_kind_name := "StorageAccount"
storageaccount_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": storageaccount_kind_name }
storageaccount_obj := {
    "apiVersion": alpha_v1,
	"kind": storageaccount_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}

virtualnetwork_kind_name := "VirtualNetwork"
virtualnetwork_kind  :={"group": az_aso_api_group ,"version": alpha_v1,"kind": virtualnetwork_kind_name }
virtualnetwork_obj := {
    "apiVersion": alpha_v1,
	"kind": virtualnetwork_kind_name,	
	"spec": {
		"location" : allowed_location_northeurope
	}
}



test_apimgmtapi_allowed_location_is_ok {
    res := violation 
    with input.review.object as apimgmt_obj
    with input.review.kind as apimgmtapi_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_apimgmtapi_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as apimgmt_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as apimgmtapi_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_apimservice_allowed_location_is_ok {
    res := violation 
    with input.review.object as apimservice_obj
    with input.review.kind as apimservice_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_apimservice_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as apimservice_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as apimservice_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_appinsights_allowed_location_is_ok {
    res := violation 
    with input.review.object as appinsights_obj
    with input.review.kind as appinsights_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_appinsights_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as appinsights_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as appinsights_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azureloadbalancer_allowed_location_is_ok {
    res := violation 
    with input.review.object as azureloadbalancer_obj
    with input.review.kind as azureloadbalancer_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azureloadbalancer_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azureloadbalancer_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azureloadbalancer_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azurenetworkinterface_allowed_location_is_ok {
    res := violation 
    with input.review.object as azurenetworkinterface_obj
    with input.review.kind as azureloadbalancer_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azurenetworkinterface_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azurenetworkinterface_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azurenetworkinterface_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azurepublicipaddress_allowed_location_is_ok {
    res := violation 
    with input.review.object as azurepublicipaddress_obj
    with input.review.kind as azurepublicipaddress_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azurepublicipaddress_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azurepublicipaddress_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azurepublicipaddress_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azuresqldatabase_allowed_location_is_ok {
    res := violation 
    with input.review.object as azuresqldatabase_obj
    with input.review.kind as azuresqldatabase_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azuresqldatabase_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azuresqldatabase_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azuresqldatabase_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azuresqlfailovergroup_allowed_location_is_ok {
    res := violation 
    with input.review.object as azuresqlfailovergroup_obj
    with input.review.kind as azuresqlfailovergroup_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azuresqlfailovergroup_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azuresqlfailovergroup_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azuresqlfailovergroup_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azuresqlserver_allowed_location_is_ok {
    res := violation 
    with input.review.object as azuresqlserver_obj
    with input.review.kind as azuresqlserver_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azuresqlserver_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azuresqlserver_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azuresqlserver_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azurevirtualmachineextension_allowed_location_is_ok {
    res := violation 
    with input.review.object as azurevirtualmachineextension_obj
    with input.review.kind as azurevirtualmachineextension_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azurevirtualmachineextension_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azurevirtualmachineextension_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azurevirtualmachineextension_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azurevirtualmachine_allowed_location_is_ok {
    res := violation 
    with input.review.object as azurevirtualmachine_obj
    with input.review.kind as azurevirtualmachine_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azurevirtualmachine_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azurevirtualmachine_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azurevirtualmachine_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_azurevmscaleset_allowed_location_is_ok {
    res := violation 
    with input.review.object as azurevmscaleset_obj
    with input.review.kind as azurevmscaleset_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_azurevmscaleset_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as azurevmscaleset_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as azurevmscaleset_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}


test_blobcontainer_allowed_location_is_ok {
    res := violation 
    with input.review.object as blobcontainer_obj
    with input.review.kind as blobcontainer_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_blobcontainer_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as blobcontainer_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as blobcontainer_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_cosmosdb_allowed_location_is_ok {
    res := violation 
    with input.review.object as cosmosdb_obj
    with input.review.kind as cosmosdb_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_cosmosdb_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as cosmosdb_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as cosmosdb_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_cosmosdb_no_locations_is_ok {
    res := violation 
    with input.review.object as cosmosdb_obj
    with input.review.object.spec.locations as null
    with input.review.kind as cosmosdb_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_cosmosdb_all_disallowed_locations_is_ko {
    
    locations_all_disallowed := [
            {
                "locationName" : disallowed_location
            },
            {
                "locationName" : disallowed_location_alt
            }
        ]
    
    res := violation 
    with input.review.object as cosmosdb_obj
    with input.review.object.spec.locations as locations_all_disallowed
    with input.review.kind as cosmosdb_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 2
}

test_cosmosdb_some_disallowed_locations_is_ko {
    
    locations_some_disallowed := [
            {
                "locationName" : allowed_location_southeurope
            },
            {
                "locationName" : disallowed_location_alt
            }
        ]
    
    res := violation 
    with input.review.object as cosmosdb_obj
    with input.review.object.spec.locations as locations_some_disallowed
    with input.review.kind as cosmosdb_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_eventhubnamespace_allowed_location_is_ok {
    res := violation 
    with input.review.object as eventhubnamespace_obj
    with input.review.kind as eventhubnamespace_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_eventhubnamespace_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as eventhubnamespace_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as eventhubnamespace_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_eventhub_allowed_location_is_ok {
    res := violation 
    with input.review.object as eventhub_obj
    with input.review.kind as eventhub_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_eventhub_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as eventhub_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as eventhub_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_keyvaultkey_allowed_location_is_ok {
    res := violation 
    with input.review.object as keyvaultkey_obj
    with input.review.kind as keyvaultkey_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_keyvaultkey_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as keyvaultkey_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as keyvaultkey_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}


test_keyvault_allowed_location_is_ok {
    res := violation 
    with input.review.object as keyvault_obj
    with input.review.kind as keyvault_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_keyvault_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as keyvault_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as keyvault_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_mysqlserver_allowed_location_is_ok {
    res := violation 
    with input.review.object as mysqlserver_obj
    with input.review.kind as mysqlserver_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_mysqlserver_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as mysqlserver_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as mysqlserver_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_postgresqlserver_allowed_location_is_ok {
    res := violation 
    with input.review.object as postgresqlserver_obj
    with input.review.kind as postgresqlserver_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_postgresqlserver_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as postgresqlserver_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as postgresqlserver_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}


test_rediscache_allowed_location_is_ok {
    res := violation 
    with input.review.object as rediscache_obj
    with input.review.kind as rediscache_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_rediscache_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as rediscache_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as rediscache_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_resourcegroup_allowed_location_is_ok {
    res := violation 
    with input.review.object as resourcegroup_obj
    with input.review.kind as resourcegroup_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_resourcegroup_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as resourcegroup_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as resourcegroup_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}


test_storageaccount_allowed_location_is_ok {
    res := violation 
    with input.review.object as storageaccount_obj
    with input.review.kind as storageaccount_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_storageaccount_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as storageaccount_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as storageaccount_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}

test_virtualnetwork_allowed_location_is_ok {
    res := violation 
    with input.review.object as virtualnetwork_obj
    with input.review.kind as virtualnetwork_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 0
}

test_virtualnetwork_disallowed_location_is_ko { 
    res := violation 
    with input.review.object as virtualnetwork_obj
    with input.review.object.spec.location as disallowed_location
    with input.review.kind as virtualnetwork_kind
    with input.parameters.allowedlocations as allowed_locations
    count(res) == 1
}