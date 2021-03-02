# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to exclude rules from the convert
data exclusionRuleList
{
    ConvertFrom-StringData -StringData @'
        V-7352   = ''
        V-73523  = ''
        V-6599   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6600   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6601   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6602   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6604   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6611   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6612   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6614   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6615   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6616   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6617   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6618   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6620   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6625   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-6627   = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-14657  = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-14658  = 'McAfee: Not Applicable to 64-bit systems.'
        V-14659  = 'McAfee: Not Applicable to 64-bit systems.'
        V-14660  = 'McAfee: Not Applicable to 64-bit systems.'
        V-14661  = 'McAfee: Not Applicable to 64-bit systems.'
        V-42563  = 'McAfee: Exclusions have been documented with, and approved by, the ISSO/ISSM/DAA'
        V-42564  = 'McAfee: Exclusions have been documented with, and approved by, the ISSO/ISSM/DAA'
        V-42565  = 'McAfee: With the assistance of the System Administrator, review each GUID key's szTaskName'
        V-42566  = 'McAfee: With the assistance of the System Administrator, review each GUID key's szTaskName'
        V-42567  = 'McAfee: With the assistance of the System Administrator, review each GUID key's szTaskName'
        V-42572  = 'McAfee: If the ExcludedURLs REG_MULTI_SZ has any entries, and the excluded URLs have not been documented with, and approved by, the ISSO/ISSM/DAA'
        V-14654  = 'McAfee: The GUID of the weekly on-demand client scan task varies by system'
        V-94025  = 'Vsphere: To Be added in a future release'
        V-207640 = 'Vsphere: To Be added in a future release'
        V-102627 = 'Windows 10: No automation available based on STIG Guidance, Fix text recommends setting up Windows Hello for non-domain systems'
        V-220946 = 'Windows 10: No automation available based on STIG Guidance, Fix text recommends setting up Windows Hello for non-domain systems'
        V-225261 = 'Windows Server 2012R2 MS: Rule was previously excluded'
        V-226051 = 'Windows Server 2012R2 DC: Rule does not apply to 2012R2 only 2012'
        V-223296 = 'Office: Unknown user data required'
        V-223297 = 'Office: Unknown user data required'
        V-223298 = 'Office: Unknown user data required'
        V-223299 = 'Office: Unknown user data required'
        V-223300 = 'Office: Unknown user data required'
        V-223301 = 'Office: Unknown user data required'
        V-223302 = 'Office: Unknown user data required'
        V-223303 = 'Office: Unknown user data required'
        V-223304 = 'Office: Unknown user data required'
        V-223305 = 'Office: Unknown user data required'
        V-223306 = 'Office: Unknown user data required'
        V-223307 = 'Office: Unknown user data required'
        V-223308 = 'Office: Unknown user data required'
        V-204393 = 'RHEL: At present, unable to automate rule'
        V-204396 = 'RHEL: At present, unable to automate rule'
        V-204398 = 'RHEL: At present, unable to automate rule'
        V-204402 = 'RHEL: At present, unable to automate rule'
        V-204404 = 'RHEL: At present, unable to automate rule'
        V-204415 = 'RHEL: At present, unable to automate rule'
        V-204417 = 'RHEL: At present, unable to automate rule'
        V-204422 = 'RHEL: At present, unable to automate rule'
        V-204424 = 'RHEL: At present, unable to automate rule'
        V-204427 = 'RHEL: At present, unable to automate rule'
        V-204428 = 'RHEL: At present, unable to automate rule'
        V-204429 = 'RHEL: At present, unable to automate rule'
        V-204432 = 'RHEL: At present, unable to automate rule'
        V-204433 = 'RHEL: At present, unable to automate rule'
        V-204436 = 'RHEL: At present, unable to automate rule'
        V-204439 = 'RHEL: At present, unable to automate rule'
        V-204488 = 'RHEL: At present, unable to automate rule'
        V-204489 = 'RHEL: At present, unable to automate rule'
        V-204496 = 'RHEL: At present, unable to automate rule'
        V-204581 = 'RHEL: At present, unable to automate rule'
        V-204582 = 'RHEL: At present, unable to automate rule'
        V-204603 = 'RHEL: At present, unable to automate rule'
        V-204605 = 'RHEL: At present, unable to automate rule'
        V-204629 = 'RHEL: At present, unable to automate rule'
        V-204632 = 'RHEL: At present, unable to automate rule'
        V-204633 = 'RHEL: Cannot automate with nxFileLineRule due to text position in conf file'
        V-204397 = 'RHEL: At present, unable to automate rule'
        V-204406 = 'RHEL: Cannot automate with nxFileLineRule due to text position in conf file'
        V-204437 = 'RHEL: Cannot automate with nxFileLineRule due to text position in conf file'
        V-204438 = 'RHEL: At present, unable to automate rule'
        V-204440 = 'RHEL: At present, unable to automate rule'
        V-204456 = 'RHEL: At present, unable to automate rule'
        V-228564 = 'RHEL: At present, unable to automate rule'
        V-219151 = 'Ubuntu: At present, unable to automate rule'
        V-219155 = 'Ubuntu: At present, unable to automate rule'
        V-219164 = 'Ubuntu: At present, unable to automate rule'
        V-219165 = 'Ubuntu: At present, unable to automate rule'
        V-219166 = 'Ubuntu: At present, unable to automate rule'
        V-219180 = 'Ubuntu: At present, unable to automate rule'
        V-219182 = 'Ubuntu: At present, unable to automate rule'
        V-219188 = 'Ubuntu: At present, unable to automate rule'
        V-219194 = 'Ubuntu: At present, unable to automate rule'
        V-219195 = 'Ubuntu: At present, unable to automate rule'
        V-219211 = 'Ubuntu: At present, unable to automate rule'
        V-219315 = 'Ubuntu: At present, unable to automate rule'
        V-219316 = 'Ubuntu: At present, unable to automate rule'
        V-219320 = 'Ubuntu: At present, unable to automate rule'
        V-219326 = 'Ubuntu: At present, unable to automate rule'
        V-219331 = 'Ubuntu: At present, unable to automate rule'
        V-219341 = 'Ubuntu: At present, unable to automate rule'
        V-235722 = 'Edge: Rule requires an unknown list and count of whitelisted domains, unable to automate rule'
        V-235753 = 'Edge: Rule requires an unknown list and count of whitelisted domains, unable to automate rule'
        V-235755 = 'Edge: Rule requires an unknown list and count of whitelisted extensions, unable to automate rule'
'@
}
