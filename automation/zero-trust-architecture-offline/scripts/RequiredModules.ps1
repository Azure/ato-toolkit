function Get-RequiredModules {
    return @(
        @{ModuleName = 'AuditPolicyDsc'; ModuleVersion = '1.2.0.0'},
        @{ModuleName = 'AuditSystemDsc'; ModuleVersion = '1.1.0'},
        @{ModuleName = 'AccessControlDsc'; ModuleVersion = '1.4.0.0'},
        @{ModuleName = 'ComputerManagementDsc'; ModuleVersion = '6.2.0.0'},
        @{ModuleName = 'FileContentDsc'; ModuleVersion = '1.1.0.108'},
        @{ModuleName = 'GPRegistryPolicyDsc'; ModuleVersion = '1.2.0'},
        @{ModuleName = 'PSDscResources'; ModuleVersion = '2.10.0.0'},
        @{ModuleName = 'SecurityPolicyDsc'; ModuleVersion = '2.4.0.0'},
        @{ModuleName = 'SqlServerDsc'; ModuleVersion = '13.3.0'},
        @{ModuleName = 'WindowsDefenderDsc'; ModuleVersion = '1.0.0.0'},
        @{ModuleName = 'xDnsServer'; ModuleVersion = '1.11.0.0'},
        @{ModuleName = 'xWebAdministration'; ModuleVersion = '2.5.0.0'},
        @{ModuleName = 'cChoco'; ModuleVersion = '2.4.0.0'},
        @{ModuleName = 'xPSDesiredStateConfiguration'; ModuleVersion = '9.1.0'}
        @{ModuleName = 'PowerSTIG'; ModuleVersion = '4.3.0'}
    )
}