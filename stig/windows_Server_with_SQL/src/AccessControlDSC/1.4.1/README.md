# AccessControlDsc

master: [![Build status](https://ci.appveyor.com/api/projects/status/sicoqw7uwykk4aup/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/AccessControlDsc/branch/master)

dev: [![Build status](https://ci.appveyor.com/api/projects/status/sicoqw7uwykk4aup/branch/dev?svg=true)](https://ci.appveyor.com/project/PowerShell/AccessControlDsc/branch/dev)

The **AccessControlDsc** module allows you to configure and manage access control on NTFS and Registry objects.  It also allows
management of audit access for Active Directory object SACL.

This project has adopted the [Microsoft Open Source Code of Conduct](
  https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](
  https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions
or comments.

## Contributing

Please check out common DSC Resources [contributing guidelines](
  https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

## Resources

* [**ActiveDirectoryAccessEntry**](#activedirectoryaccessentry): Provides the ability to manage access entries for Active Directory objects.

* [**ActiveDirectoryAuditRule**](#activedirectoryauditrule): Provides the ability to manage audit access for Active Directory object SACL.

* [**NtfsAccessEntry**](#ntfsaccessentry): Provides the ability to manage access entries for NTFS files and directories.

* [**RegistryAccessEntry**](#registryaccessentry):  Provides the ability to manage access entries for Registry objects.

### **ActiveDirectoryAccessEntryRule**

* **[String] DistinguishedName** _(Key)_: Indicates the Distinguished Name value for the target Active Directory Object.

* **[String] AccessControlList**: Indicates the access control information in the form of an array of instances of the ActiveDirectoryAccessControlList CIM class. Includes the following properties:

  * **[String] Principal:** Indicates the identity of the principal.

  * **[String] AccessControlEntry:** Indicates the access control entry in the form of an array of instances of the AccessControlList CIM class.  Includes the following properties:

    * **[String] AccessControlType:** Specifies whether an AccessRule object is used to allow or deny access. _{ Allow | Deny }_

    * **[String] ActiveDirectoryRights:** Specifies the access rights that are assigned to an Active Directory Domain Services object. _{ AccessSystemSecurity | CreateChild | Delete | DeleteChild | DeleteTree | ExtendedRight | GenericAll | GenericExecute | GenericRead | GenericWrite | ListChildren | ListObject | ReadControl | ReadProperty | Self | WriteDacl | WriteOwner | WriteProperty }_

    * **[String] Ensure:** Whether the rights should be present or absent. _{ Ensure | Present }_

    * **[String] InheritanceType:** Specifies if, and how, ACE information is applied to an object and its descendents. _{ All | Children | Descendents | None | SelfAndChildren }_

    * **[String] InheritedObjectType:** Specifies the object type name that identifies the type of child object that can inherit this access rule.

    * **[String] ObjectType:** Specifies the object type name that identifies the type of child object that can inherit this access rule.

  * **[String] ForcePrincipal:** Indicates whether the rights for this principal should be forced.  Will remove any rights not explicitly defined in the configuration for the principal.

#### ActiveDirectoryAccessRule Examples

* [Set Active Directory OU access rules](
  https://github.com/mcollera/AccessControlDsc/blob/master/Examples/ActiveDirectoryAccessEntry_example.ps1)

### **ActiveDirectoryAuditRule**

* **[String] DistinguishedName** _(Key)_: Indicates the Distinguished Name value for the target Active Directory Object.

* **[String] AccessControlList**: Indicates the access control information in the form of an array of instances of the ActiveDirectoryAuditRuleList CIM class. Includes the following properties:

  * **[String] Principal:** Indicates the identity of the principal.

  * **[String] AccessControlEntry:** Indicates the access control entry in the form of an array of instances of the AccessControlList CIM class.  Includes the following properties:

    * **[String] AuditFlags:** Specifies the conditions for auditing attempts to access a securable object. _{ Success | Failure }_

    * **[String] ActiveDirectoryRights:** Specifies the access rights that are assigned to an Active Directory Domain Services object. _{ AccessSystemSecurity | CreateChild | Delete | DeleteChild | DeleteTree | ExtendedRight | GenericAll | GenericExecute | GenericRead | GenericWrite | ListChildren | ListObject | ReadControl | ReadProperty | Self | WriteDacl | WriteOwner | WriteProperty }_

    * **[String] Ensure:** Whether the rights should be present or absent. _{ Ensure | Present }_

    * **[String] InheritanceType:** Specifies if, and how, ACE information is applied to an object and its descendents. _{ All | Children | Descendents | None | SelfAndChildren }_

    * **[String] InheritedObjectType:** Specifies the object type name that identifies the type of child object that can inherit this access rule.

  * **[String] ForcePrincipal:** Indicates whether the rights for this principal should be forced.  Will remove any rights not explicitly defined in the configuration for the principal.

* **[Boolean] Force:** Indicates whether the rights defined should be enforced.  Will remove any rights not explicitly defined in the configuration for the path.

#### ActiveDirectoryAuditRule Examples

* [Set Active Directory OU audit access rules](
  https://github.com/mcollera/AccessControlDsc/blob/master/Examples/ActiveDirectoryAuditRuleEntry_example.ps1)

### **NtfsAccessEntry**

* **[String] Path** _(Key)_: Indicates the path to the target item.

* **[String] AccessControlList**: Indicates the access control information in the form of an array of instances of the NTFSAccessControlList CIM class. Includes the following properties:

  * **[String] Principal:** Indicates the identity of the principal.

  * **[String] AccessControlEntry:** Indicates the access control entry in the form of an array of instances of the AccessControlList CIM class.  Includes the following properties:

    * **[String] AccessControlType:** Indicates whether to allow or deny access to the target item. _{ Allow | Deny }_

    * **[String] FileSystemRights:** Indicates the access rights to be granted to the principal. _{ AppendData | ChangePermissions | CreateDirectories | CreateFiles | Delete | DeleteSubdirectoriesAndFiles | ExecuteFile | FullControl | ListDirectory | Modify | Read | ReadAndExecute | ReadAttributes | ReadData | ReadExtendedAttributes | ReadPermissions | Synchronize | TakeOwnership | Traverse | Write | WriteAttributes | WriteData | WriteExtendedAttributes }_

    * **[String] Ensure:** Whether the rights should be present or absent. _{ Ensure | Present }_

    * **[String] Inheritance:** Indicates the inheritance type of the permission entry.

  * **[String] ForcePrincipal:** Indicates whether the rights for this principal should be forced.  Will remove any rights not explicitly defined in the configuration for the principal.

* **[Boolean] Force:** Indicates whether the rights defined should be enforced.  Will remove any rights not explicitly defined in the configuration for the path.

#### NtfsAccessEntry Examples

* [Set access entries for NTFS folders](
  https://github.com/mcollera/AccessControlDsc/blob/master/Examples/NtfsAccessEntry_example.ps1)

### **RegistryAccessEntry**

* **[String] Path** _(Key)_: Indicates the path to the target item.

* **[String] AccessControlList**: Indicates the access control information in the form of an array of instances of the RegistryRule CIM class. Includes the following properties:

  * **[String] Principal:** Indicates the identity of the principal.

  * **[String] AccessControlEntry:** Indicates the access control entry in the form of an array of instances of the AccessControlList CIM class.  Includes the following properties:

    * **[String] AccessControlType:** Indicates whether to allow or deny access to the target item. _{ Allow | Deny }_

    * **[String] Rights:** Indicates the access rights to be granted to the principal. _{ ChangePermissions | CreateLink | CreateSubKey | Delete | EnumerateSubKeys | ExecuteKey | FullControl | Notify | QueryValues | ReadKey | ReadPermissions | SetValue | TakeOwnership | WriteKey }_

    * **[String] Ensure:** Whether the rights should be present or absent. _{ Ensure | Present }_

    * **[String] Inheritance:** Indicates the inheritance type of the permission entry. _{ This Key Only | This Key and Subkeys | SubKeys Only }_

  * **[String] ForcePrincipal:** Indicates whether the rights for this principal should be forced.  Will remove any rights not explicitly defined in the configuration for the principal.

* **[Boolean] Force:** Indicates whether the rights defined should be enforced.  Will remove any rights not explicitly defined in the configuration for the path.

#### RegistryAccessEntry Examples

* [Configure access entries for registry key](
  https://github.com/mcollera/AccessControlDsc/blob/master/Examples/RegistryAccessEntry_example.ps1)

### **FileSystemAuditRuleEntry**

* **[String] Path** _(Key)_: Indicates the path to the target item.

* **[String] AuditRuleList**: Indicates the audit rule information in the form of an array of instances of the FileSystemAuditRuleList CIM class. Includes the following properties:

  * **[String] Principal:** Indicates the identity of the principal.

  * **[String] AuditRuleEntry:** Indicates the audit rule entry in the form of an array of instances of the FileSystemAuditRule CIM class.  Includes the following properties:

    * **[String] AuditFlags:** Specifies the conditions for auditing attempts to access a securable object. _{ None | Success | Failure }_

    * **[String] FileSystemRights:** Indicates the access rights to be granted to the principal. _{ AppendData | ChangePermissions | CreateDirectories | CreateFiles | Delete | DeleteSubdirectoriesAndFiles | ExecuteFile | FullControl | ListDirectory | Modify | Read | ReadAndExecute | ReadAttributes | ReadData | ReadExtendedAttributes | ReadPermissions | Synchronize | TakeOwnership | Traverse | Write | WriteAttributes | WriteData | WriteExtendedAttributes }_

    * **[String] Inheritance:** Indicates the inheritance type of the permission entry. _{ This folder only | This folder subfolders and files | This folder and subfolders | This folder and files | Subfolders and files only | Subfolders only | Files only }_

    * **[String] Ensure:** Whether the rights should be present or absent. _{ Ensure | Present }_

  * **[String] ForcePrincipal:** Indicates whether the rights for this principal should be forced.  Will remove any rights not explicitly defined in the configuration for the principal.

* **[String] Force:** Indicates whether the audit rules defined should be enforced. Will remove any audit rules not explicitly defined in the configuration for the path.

#### FileSystemAuditRuleEntry Examples

* [Configure Failure and Success AuditFlags](
  https://github.com/mcollera/AccessControlDsc/blob/master/Examples/FileSystemAuditRuleEntry_example.ps1)

## Versions

### 1.3.0.0

* Bug Fix [#44](https://github.com/mcollera/AccessControlDsc/issues/44)
* Bug Fix [#46](https://github.com/mcollera/AccessControlDsc/issues/46)

### 1.2.0.0

* Bug Fix [#40](https://github.com/mcollera/AccessControlDsc/issues/40)

### 1.1.0.0

* Added ActiveDirectoryAccessEntry resource
* **Breaking Change:** Modified ActiveDirectoryAuditRuleEntry *ActiveDirectoryRights* parameter values to match [System.DirectoryServices.ActiveDirectoryRights](https://msdn.microsoft.com/en-us/library/system.directoryservices.activedirectoryrights(v=vs.110).aspx) members

### 1.0.0.0

* Initial release with the following resources:

  * ActiveDirectoryAuditRule
  * NtfsAccessEntry
  * RegistryAccessEntry
