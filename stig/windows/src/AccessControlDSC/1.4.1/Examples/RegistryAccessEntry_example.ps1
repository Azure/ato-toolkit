Configuration TestAceResource 
{
    Import-DscResource -Module AccessControlDsc

    Node 'localhost' 
    {
        RegistryAccessEntry TestKeyAccess
        {
            Path = "HKLM:\SOFTWARE\Dsc_Test"
            AccessControlList = @(
                AccessControlList
                {
                    Principal = "Everyone"
                    ForcePrincipal = $True
                    AccessControlEntry = @(
                        AccessControlEntry
                        {
                            AccessControlType = 'Allow'
                            Rights = 'FullControl'
                            Inheritance = 'This Key and Subkeys'
                            Ensure = 'Present'
                        }
                    )               
                }
                AccessControlList
                {
                    Principal = "Users"
                    ForcePrincipal = $True
                    AccessControlEntry = @(
                        AccessControlEntry
                        {
                            AccessControlType = 'Allow'
                            Rights = 'ReadKey'
                            Inheritance = 'This Key Only'
                            Ensure = 'Present'
                        }
                    )               
                }
            )
        }
    }
}
