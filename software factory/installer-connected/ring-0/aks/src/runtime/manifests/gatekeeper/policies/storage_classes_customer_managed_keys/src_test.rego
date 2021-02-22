package com.microsoft.c12.ecnryptionatrest

pvc_kind := {
	"kind": {
		"group": "",
        "kind": "PersistentVolumeClaim",
        "version": "v1",
    }
}

encrypted_storage_class_name := "managed-premium-encrypted"
encrypted_storage_class := {
	"allowVolumeExpansion": true,
    "apiVersion": "storage.k8s.io/v1",
    "kind": "StorageClass",
    "metadata": {      
      "name": encrypted_storage_class_name,
    },
    "parameters": {
      "cachingmode": "ReadOnly",
      "kind": "Managed",
      "storageaccounttype": "Premium_LRS",
	  "diskEncryptionSetID": "/subscriptions/myAzureSubscriptionId/resourceGroups/myResourceGroup/providers/Microsoft.Compute/diskEncryptionSets/myDiskEncryptionSetName",
    },
    "provisioner": "kubernetes.io/azure-disk",
    "reclaimPolicy": "Delete",
    "volumeBindingMode": "Immediate"
}

unencrypted_storage_class_name := "managed-premium-notencrypted"
unencrypted_storage_class := {
	"allowVolumeExpansion": true,
    "apiVersion": "storage.k8s.io/v1",
    "kind": "StorageClass",
    "metadata": {      
      "name": unencrypted_storage_class_name,
    },
    "parameters": {
      "cachingmode": "ReadOnly",
      "kind": "Managed",
      "storageaccounttype": "Premium_LRS"
    },
    "provisioner": "kubernetes.io/azure-disk",
    "reclaimPolicy": "Delete",
    "volumeBindingMode": "Immediate"
}

other_storage_class_name := "azurefile"
other_storage_class := {
	"allowVolumeExpansion": true,
    "apiVersion": "storage.k8s.io/v1",
    "kind": "StorageClass",
    "metadata": {     
      "name": other_storage_class_name,
    },
    "parameters": {
      "skuName": "Standard_LRS"
    },
    "provisioner": "kubernetes.io/azure-file",
    "reclaimPolicy": "Delete",
    "volumeBindingMode": "Immediate"
}

all_storage_classes := {
	"cluster" : {
		"storage.k8s.io/v1" : {
			"StorageClass" : {
				encrypted_storage_class_name: encrypted_storage_class,
				unencrypted_storage_class_name: unencrypted_storage_class,
				other_storage_class_name:  other_storage_class 
			}
		}
	}		
	
}

encryptedPvcName := "pvc_encrypted"
encrypted_pvc := {
 	"apiVersion": "v1",
	"kind": "PersistentVolumeClaim",
	"metadata": {
	"annotations": {
		"pv.kubernetes.io/bind-completed": "yes",
		"pv.kubernetes.io/bound-by-controller": "yes",
		"volume.beta.kubernetes.io/storage-provisioner": "kubernetes.io/azure-disk"
	},	
	"name": encryptedPvcName,
	"namespace": "jopedros",		
	},
	"spec": {
		"accessModes": [
			"ReadWriteOnce"
		],
		"resources": {
			"requests": {
			"storage": "30Gi"
			}
		},
		"storageClassName": encrypted_storage_class_name,
		"volumeMode": "Filesystem",
		"volumeName": "pvc-f8766f66-7e76-42b9-8abe-ad38f5b62a38"
	},	
}

unencrypted_pvc_name := "unencrypted_pvc"
unencrypted_pvc := {
 	"apiVersion": "v1",
	"kind": "PersistentVolumeClaim",
	"metadata": {
	"annotations": {
		"pv.kubernetes.io/bind-completed": "yes",
		"pv.kubernetes.io/bound-by-controller": "yes",
		"volume.beta.kubernetes.io/storage-provisioner": "kubernetes.io/azure-disk"
	},
	"name": unencrypted_pvc_name,
	"namespace": "jopedros",		
	},
	"spec": {
		"accessModes": [
			"ReadWriteOnce"
		],
		"resources": {
			"requests": {
			"storage": "30Gi"
			}
		},
		"storageClassName": unencrypted_storage_class_name,
		"volumeMode": "Filesystem",
		"volumeName": "pvc-f8766f66-7e76-42b9-8abe-ad38f5b62a38"
	}
}

other_pvc_name := "other_pvc"
other_pvc := {
	"apiVersion": "v1",
	"kind": "PersistentVolumeClaim",
	"metadata": {
	"annotations": {
			"pv.kubernetes.io/bind-completed": "yes",
			"pv.kubernetes.io/bound-by-controller": "yes",
			"volume.beta.kubernetes.io/storage-provisioner": "kubernetes.io/azure-disk"
	},
	"name": other_pvc_name,
	"namespace": "jopedros",		
	},
	"spec": {
		"accessModes": [
			"ReadWriteOnce"
		],
		"resources": {
			"requests": {
			"storage": "30Gi"
			}
		},
		"storageClassName": other_storage_class_name,
		"volumeMode": "Filesystem",
		"volumeName": "pvc-f8766f66-7e76-42b9-8abe-ad38f5b62a38"
	},
}


pvc_no_storage_class_name := "silent_pvc"
pvc_no_storage_class := {
	"apiVersion": "v1",
	"kind": "PersistentVolumeClaim",
	"metadata": {
		"annotations": {
			"pv.kubernetes.io/bind-completed": "yes",
			"pv.kubernetes.io/bound-by-controller": "yes",
			"volume.beta.kubernetes.io/storage-provisioner": "kubernetes.io/azure-disk"
		},		
		"name": other_pvc_name,
		"namespace": "jopedros",
	},
	"spec": {
		"accessModes": [
			"ReadWriteOnce"
		],
		"resources": {
			"requests": {
			"storage": "30Gi"
			}
		},
		"volumeMode": "Filesystem",
		"volumeName": "pvc-f8766f66-7e76-42b9-8abe-ad38f5b62a38"
	}
}


encrypted_pvc_input := {
	"review" :{
		"kind" : pvc_kind,
		"name": encryptedPvcName,
		"object" : encrypted_pvc,		
	}
}

unencrypted_pvc_input := {
	"review" :{
		"kind" : pvc_kind,
		"name" : unencrypted_pvc_name,
		"object" : unencrypted_pvc,		
	}
}

other_pvc_input := {
	"review" :{
		"kind" : pvc_kind,
		"name": other_pvc_name,
		"object" : other_pvc,		
	}
}

no_storage_class_pvc_input := {
	"review" :{
		"kind" : pvc_kind,
		"name": pvc_no_storage_class_name,
		"object" : pvc_no_storage_class,		
	}
}


test_pvc_uses_encrypted_storage_class_is_ok {
	res := violation with input as encrypted_pvc_input with data.inventory as all_storage_classes
	count(res) == 0	
}

test_pvc_uses_unencrypted_storage_class_is_ko {	
	res := violation with input as unencrypted_pvc_input with data.inventory as all_storage_classes
	count(res) == 1
}

test_pvc_non_maneged_disk_ko {
	res := violation with input as other_pvc_input with data.inventory as all_storage_classes
	count(res) == 1
}

test_pvc_non_storage_class_ko {
	res := violation with input as no_storage_class_pvc_input with data.inventory as all_storage_classes
	count(res) == 1
}
