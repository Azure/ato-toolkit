
#region HEADER

# Unit Test Template Version: 1.2.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ((-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName 'WindowsDefenderDsc' `
    -DSCResourceName 'ProcessMitigation' `
    -TestType Unit



#endregion HEADER


function Invoke-TestCleanup {
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try
{
    InModuleScope 'ProcessMitigation' {


    $getProcessMitigationMock = @{
        ProcessName = @{
            System = @{
                Heap  = @{
                    TerminateOnError = 'ON'
                }
                SEHOP = @{
                    Enable                = 'OFF'
                    BlockRemoteImageLoads = 'NOTSET'
                }
                DEP   = @{
                    Enable           = 'ON'
                    EmulateAtlThunks = 'NOTSET'
                }
                ASLR  = @{
                    BottomUp = 'OFF'
                }
            }
        }
    }

        Describe 'Get-CurrentProcessMitigation'{
            Context 'When getting current Process Mitigation Settings' {
                Mock -CommandName Get-ProcessMitigation -MockWith { $getProcessMitigationMock }
                $currentProcessMitigationResult = Get-CurrentProcessMitigationSettings

                It 'Should return 14 Mitigation types per target' {
                    $currentProcessMitigationResult.Values.Keys.Count | Should -Be 14
                }

                It 'Should return 14 Mitigation Names per target' {
                    $currentProcessMitigationResult.Values.Values.Count | Should -Be 14
                }

                It 'Should return type object array' {
                    $currentProcessMitigationResult.GetType().Name | Should -Be 'Hashtable'
                }
            }
        }

        Describe 'Get-CurrentProcessMitigationXml'{
            Context 'When generating new XML from converted results' {
                Mock -CommandName Get-ProcessMitigation -MockWith { $getProcessMitigationMock }
                $currentProcessMitigationResult = Get-CurrentProcessMitigationSettings
                $CurrentProcessMitigationXml = Get-CurrentProcessMitigationXml -CurrentMitigationsConverted $currentProcessMitigationResult

                It 'Should return the path of the new xml'{
                    $CurrentProcessMitigationXml | Should -BeLike "*\AppData\Local\Temp\MitigationsCurrent.xml"
                }
            }
        }


        $testParameters = @(
            @{
                MitigationTarget = "winword.exe"
                MitigationType = "DEP"
                MitigationName = "OverrideDEP"
                MitigationValue = "true"
            },
            @{
                MitigationTarget = "{0}_{1}" -f "DOESNTEXIST", (Get-Random)
                MitigationType = "DEP"
                MitigationName = "OverrideDEP"
                MitigationValue = "true"
            },
            @{
                MitigationTarget = "winword.exe"
                MitigationType = "DEP"
                MitigationName = "OverrideDEP"
                MitigationValue = "false"
            },
            @{
                MitigationTarget = "System"
                MitigationType = "DEP"
                MitigationName = "OverrideDEP"
                MitigationValue = "true"
            },
            @{
                MitigationTarget = "System"
                MitigationType = "DynamicCode"
                MitigationName = "Audit"
                MitigationValue = "true"
            },
            @{
                MitigationTarget = "System"
                MitigationType = "DynamicCode"
                MitigationName = "Audit"
                MitigationValue = "false"
            }
        )

        foreach ($parameterSet in $testParameters)
        {
            Describe 'Get-TargetResource'{
                Context 'When Get-TargetResource is called' {
                    Mock -CommandName Get-ProcessMitigation -MockWith { $getProcessMitigationMock }
                    $result = Get-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue

                    It 'Should not throw'{
                        {Get-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue} | Should -Not -Throw
                    }

                    It 'Should return a hashtable'{
                    $result | Should -BeOfType Hashtable
                    }
                }
            }

            Describe 'Test-TargetResource'{
                Context 'When Test-TargetResource is called' {
                    Mock -CommandName Get-ProcessMitigation -MockWith { $getProcessMitigationMock }
                    $result = Test-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue
                    if ($parameterSet.MitigationTarget -eq "System")
                    {
                        [string] $resultCurrent = (Get-ProcessMitigation -System).($parameterSet.MitigationType).($parameterSet.MitigationName)
                    }
                    else
                    {
                        [string] $resultCurrent = (Get-ProcessMitigation -Name $parameterSet.MitigationTarget).($parameterSet.MitigationType).($parameterSet.MitigationName)
                    }

                    if($resultCurrent -eq "ON")
                    {
                        $resultCurrent = "true"
                    }

                    if ($parameterSet.MitigationValue -eq $resultCurrent)
                    {
                        It 'Should return true'{
                            $result | Should -Be $true
                        }
                    }
                    else
                    {
                        It 'Should return false'{
                            $result | Should -Be $false
                        }
                    }

                    It 'Should not throw'{
                        {Test-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue} | Should -Not -Throw
                    }
                }
            }

            Describe 'Set-TargetResource'{
                Context 'When Set-TargetResource is called' {
                    Mock -CommandName Get-ProcessMitigation -MockWith { $getProcessMitigationMock }
                    Set-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue
                    $result = Test-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue
                    $resultSet = (Get-ProcessMitigation -Name $parameterSet.MitigationTarget).($parameterSet.MitigationType).($parameterSet.MitigationName)

                    if ($resultSet -eq "OFF" -or $resultSet -eq $false)
                    {
                        $resultSet = "false"
                    }

                    if($resultSet -eq $true)
                    {
                        $resultSet = "true"
                    }

                    if ($resultSet -eq $parameterSet.MitigationValue) {
                        It "Should be equal to $($parameterSet.MitigationValue)"{
                            $result | Should -be $true
                        }
                    }

                    It 'Should not throw'{
                        {Set-TargetResource -MitigationTarget $parameterSet.MitigationTarget -MitigationType $parameterSet.MitigationType -MitigationName $parameterSet.MitigationName -MitigationValue $parameterSet.MitigationValue} | Should -Not -Throw
                    }
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
