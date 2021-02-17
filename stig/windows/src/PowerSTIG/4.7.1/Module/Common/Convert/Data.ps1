# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# This is used to exclude rules from the convert
data exclusionRuleList
{
    ConvertFrom-StringData -StringData @'
        V-73523 = ''
        V-225261 = 'Windows Server 2012R2 MS: Rule was previously excluded'
        V-226051 = 'Windows Server 2012R2 DC: Rule does not apply to 2012R2 only 2012'
        V-6599 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6600 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6601 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6602 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6604 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6611 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6612 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6614 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6615 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6616 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6617 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6618 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6620 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6625 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-6627 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-14657 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-14658 = 'McAfee: Not Applicable to 64-bit systems.'
        V-14659 = 'McAfee: Not Applicable to 64-bit systems.'
        V-14660 = 'McAfee: Not Applicable to 64-bit systems.'
        V-14661 = 'McAfee: Not Applicable to 64-bit systems.'
        V-42563 = 'McAfee:exclusions have been documented with, and approved by, the ISSO/ISSM/DAA'
        V-42564 = 'McAfee:exclusions have been documented with, and approved by, the ISSO/ISSM/DAA'
        V-42565 = 'McAfee:with the assistance of the System Administrator, review each GUID key's szTaskName'
        V-42566 = 'McAfee:with the assistance of the System Administrator, review each GUID key's szTaskName'
        V-42567 = 'McAfee:with the assistance of the System Administrator, review each GUID key's szTaskName'
        V-42572 = 'McAfee:If the ExcludedURLs REG_MULTI_SZ has any entries, and the excluded URLs have not been documented with, and approved by, the ISSO/ISSM/DAA'
        V-14654 = 'McAfee:The GUID of the weekly on-demand client scan task varies by system'
        V-94509 = 'Vsphere: To Be added in a future release'
        V-94025 = 'Vsphere: To Be added in a future release'
        V-94533 = 'Vsphere: To Be added in a future release'
        V-102627 = 'No automation available based on STIG Guidance, Fix text recommends setting up Windows Hello for non-domain systems'
        V-220946 = 'No automation available based on STIG Guidance, Fix text recommends setting up Windows Hello for non-domain systems'
'@
}
