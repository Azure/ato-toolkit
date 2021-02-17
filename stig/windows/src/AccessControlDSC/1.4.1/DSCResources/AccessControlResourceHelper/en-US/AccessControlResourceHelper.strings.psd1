ConvertFrom-StringData -StringData @'
    ErrorPathNotFound        = The requested path '{0}' cannot be found.
    AclNotFound              = Error obtaining '{0}' ACL.
    AclFound                 = Obtained '{0}' ACL.
    RemoveAccessError        = Unable to remove access for '{0}'.
    RemoveAuditError         = Unable to remove audit for '{0}'.
    InheritanceDetectedForce = Force set to '{0}', Inheritance detected on path '{1}', returning 'false'
    ResetDisableInheritance  = Disabling inheritance and wiping all existing inherited rules.
    ActionAddAccess          = Adding access rule:
    ActionAddAudit           = Adding audit rule:
    ActionRemoveAccess       = Removing access rule:
    ActionRemoveAudit        = Removing audit rule:
    ActionResetAdd           = Resetting explicit access control list and adding access rule:
    ActionNonMatchPermission = Non-matching permission entry found:
    ActionNonMatchAudit      = Non-matching audit rule found:
    ActionMissPresentPerm    = Found missing [Ensure = Present] permission rule:
    ActionMissPresentAudit   = Found missing [Ensure = Present] audit rule:
    ActionAbsentPermission   = Found [Ensure = Absent] permission rule:
    ActionAbsentAudit        = Found [Ensure = Absent] audit rule:
    Path                     = > Path                  : '{0}'
    IdentityReference        = > IdentityReference     : '{0}'
    AccessControlType        = > AccessControlType     : '{0}'
    FileSystemRights         = > FileSystemRights      : '{0}'
    ActiveDirectoryRights    = > ActiveDirectoryRights : '{0}'
    InheritanceFlags         = > InheritanceFlags      : '{0}'
    PropagationFlags         = > PropagationFlags      : '{0}'
    AuditFlags               = > AuditFlags            : '{0}'
    ObjectType               = > ObjectType            : '{0}'
    InheritanceType          = > InheritanceType       : '{0}'
    InheritedObjectType      = > InheritedObjectType   : '{0}'
'@
