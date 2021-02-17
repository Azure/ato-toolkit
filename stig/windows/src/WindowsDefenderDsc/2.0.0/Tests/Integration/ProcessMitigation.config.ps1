# Integration Test Config Template Version: 1.0.0

$processMitgationParameters = @(
    @{
        MitigationTarget = 'SYSTEM'
        MitigationType   = 'DEP'
        MitigationName   = 'Enable'
        MitigationValue  = 'true'
    },
    @{
        MitigationTarget = 'SYSTEM'
        MitigationType   = 'ASLR'
        MitigationName   = 'OverrideForceRelocateImages'
        MitigationValue  = 'true'
    }
)

configuration ProcessMitigation_config {

    Import-DscResource -ModuleName 'WindowsDefenderDsc'

    node localhost {

        foreach($processMitigationParameter in $processMitigationParameter)
        {
            ProcessMitigation $processMitgationParameters.MitigationType
            {
                MitigationTarget = $processMitgationParameters.MitigationTarget
                MitigationType   = $processMitgationParameters.MitigationType
                MitigationName   = $processMitgationParameters.MitigationName
                MitigationValue  = $processMitgationParameters.MitigationValue
            }
        }
    }
}
