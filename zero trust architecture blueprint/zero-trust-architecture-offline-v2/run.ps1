param(
    [Parameter(Mandatory = $false, HelpMessage = 'namePrefix')]
    [string] $namePrefix
)

$jConfig = Get-Content "./run.config.json" | ConvertFrom-Json

$tempPath = $jConfig.args.tempPath
$policyTemplate = $jConfig.args.policyTemplate
$artifactsPath = $jConfig.args.artifactsPath
$policyAssignmentPrefix = $jConfig.args.policyAssignmentPrefix
$onlyGenerateTemplates = $jConfig.args.onlyGenerateTemplates
$deploymentUserObjectIdParameterName = "deployment-user-object-id"

$resourceLocation = $jConfig.parameters.location.value
$resourceLocation = if ($null -eq $resourceLocation -or "" -eq $resourceLocation) { $jConfig.parameters.workspaceLocation.value } else { $resourceLocation }
$jDefaultParams = Get-Content $jConfig.args.defaultParams | ConvertFrom-Json

function Add-DefaultParamsToTemplate {
    param (
        $jTemplate,
        $jParameterProperties
    )
    
    foreach ($paramNames in $jParameterProperties.psobject.properties.value) {
        $defaultParams = Get-DefaultParameterValues -paramName $null -paramNames $paramNames
        foreach ($defaultParam in $defaultParams.keys) {
            if ($null -ne $defaultParams[$defaultParam] -and $jTemplate.parameters.psobject.properties.name -notcontains $defaultParam) {
                $jTemplate.parameters | add-member -Name $defaultParam -value $defaultParams[$defaultParam] -MemberType NoteProperty
            }
        }
    }
}

function Get-DefaultParameterValues {
    param (
        $paramName,
        $paramNames
    )

    $defaultParams = @{ }
    $pattern = 'parameters\(''(?<name>[^\s]*)''\)'
    foreach ($g in Select-String -InputObject $paramNames -Pattern $pattern -AllMatches | % { $_.matches.groups }) {
        if ($g.Name -eq "name" -and $jDefaultParams.properties.parameters.psobject.properties.name -contains $g.value) {
            if ($null -eq $paramName) {
                $defaultParams[$g.value] = $jDefaultParams.properties.parameters.$($g.value)
            }
            else {
                $defaultParams[$paramName] = $jDefaultParams.properties.parameters.$($g.value)
            }            
        }
    }

    return $defaultParams
}

function Get-TemplateParameters {
    param (
        $jParameters
    )

    $templateParameters = @{ }
    foreach ($paramName in $jParameters.psobject.properties.name) {
        foreach ($name in $jConfig.parameters.psobject.properties.name) {
            if ($name -eq $paramName -and $null -ne $jConfig.parameters.$($name)) {
                if ($name -eq "location") {
                    $templateParameters[$paramName] = $resourceLocation
                }
                else {
                    $templateParameters[$paramName] = $jConfig.parameters.$($name)
                }
            }
        }
    }
   
    if ($null -ne $templateParameters.$deploymentUserObjectIdParameterName) {
        if ($null -eq $templateParameters.$deploymentUserObjectIdParameterName.value -or "" -eq $templateParameters.$deploymentUserObjectIdParameterName.value) {
            if ($onlyGenerateTemplates -eq $false) {
                $userObjectId = (Get-AzADUser -UserPrincipalName (Get-AzContext).Account.Id).Id
                $templateParameters[$deploymentUserObjectIdParameterName] = @{ "value" = $userObjectId }
            }
        }
    }

    return $templateParameters
}

function New-PolicyAssignment {
    param (
        $artifact
    )

    $jArtifact = Get-Content $artifact | ConvertFrom-Json
    if ($jArtifact.kind -ne "policyAssignment") {
        Write-Host "Artifact '$($artifact)' is not a valid policyAssignment. Skipping..."
        return
    }

    $jPolicyTemplate = Get-Content $policyTemplate | ConvertFrom-Json
    $jPolicyTemplate.resources.properties | add-member -Name "parameters" -Value $jArtifact.properties.parameters -MemberType NoteProperty
    Add-DefaultParamsToTemplate -jTemplate $jPolicyTemplate -jParameterProperties $jPolicyTemplate.resources.properties.parameters
    Add-DefaultParamsToTemplate -jTemplate $jPolicyTemplate -jParameterProperties $jPolicyTemplate.parameters

    $templateParameters = Get-TemplateParameters -jParameters $jPolicyTemplate.parameters
    $templateParameters.policyAssignmentName = @{ }
    $policyAssignmentName = "$($policyAssignmentPrefix)$($jArtifact.properties.displayName)"
    if ($policyAssignmentName.Length -lt 65) {
        $templateParameters.policyAssignmentName.value = $policyAssignmentName.Trim()
    }
    else {
        $templateParameters.policyAssignmentName.value = $policyAssignmentName.Substring(0, 64).Trim()
    }
    $templateParameters.policyDefinitionID = @{ }
    $templateParameters.policyDefinitionID.value = $jArtifact.properties.policyDefinitionId
    $templateParameters.location.value = $resourceLocation

    $policyTemplateFile = "$($tempPath)/policy.$($jArtifact.name).json"
    $jPolicyTemplate | ConvertTo-Json -Depth 100 | Set-Content $policyTemplateFile
    $policyTemplateParameterFile = "$($tempPath)/policy.$($jArtifact.name).parameters.json"
    $templateParameters | ConvertTo-Json -Depth 100 | Set-Content $policyTemplateParameterFile

    if ($onlyGenerateTemplates -eq $false) {
        New-AzDeployment -Location $resourceLocation -TemplateFile $policyTemplateFile -TemplateParameterFile $policyTemplateParameterFile 
    }
}

function New-ResourceDeployment {
    param (
        $artifact
    )

    $jArtifact = Get-Content $artifact | ConvertFrom-Json
    if ($null -ne $jArtifact.properties.template) {
        $jResourceTemplate = $jArtifact.properties.template
    }
    else {
        $jResourceTemplate = $jArtifact
    }
    
    foreach ($param in $jArtifact.properties.parameters.psobject.properties) {
        $defaultParamValues = Get-DefaultParameterValues -paramName $param.name -paramNames $param.value -jDefaultParams $jDefaultParams
        $jResourceTemplate.parameters.$($param.name) = $defaultParamValues[$param.name]
    }

    $tempFileName = if ($null -eq $jArtifact.name) { (Split-Path -Path $artifact -Leaf).Split(".")[0] } else { $jArtifact.name }
    $resourceTemplateFile = "$($tempPath)/resource.$($tempFileName).json"
    $jResourceTemplate | ConvertTo-Json -Depth 100 | Set-Content $resourceTemplateFile -Force
    $resourceTemplateParameterFile = "$($tempPath)/resource.$($tempFileName).parameters.json"
    Get-TemplateParameters -jParameters $jResourceTemplate.parameters -jConfig $jConfig | ConvertTo-Json -Depth 100 | Set-Content $resourceTemplateParameterFile -Force
    
    if ($onlyGenerateTemplates -eq $false) {
        if ($jResourceTemplate.'$schema'.EndsWith("subscriptionDeploymentTemplate.json#")) {
            New-AzDeployment -Location $resourceLocation -TemplateFile $resourceTemplateFile -TemplateParameterFile $resourceTemplateParameterFile
        }
        else {
            $namePrefix = ""
            $name = ""

            if ($null -ne $jConfig.parameters.namePrefix.value -and "" -ne $jConfig.parameters.namePrefix.value) {
                $namePrefix = $jConfig.parameters.namePrefix.value
            }
            else {
                $namePrefix = $jResourceTemplate.parameters.namePrefix.defaultValue
            }

            if ($null -ne $jResourceTemplate.parameters.spokeName -and $null -ne $jConfig.parameters.spokeName.value -and "" -ne $jConfig.parameters.spokeName.value) {
                $name = $jConfig.parameters.spokeName.value
            }
            elseif ($null -ne $jResourceTemplate.parameters.spokeName.defaultValue -and "" -ne $jResourceTemplate.parameters.spokeName.defaultValue) {
                $name = $jResourceTemplate.parameters.spokeName.defaultValue
            }
            elseif ($null -ne $jConfig.parameters.hubName.value -and "" -ne $jConfig.parameters.hubName.value) {
                $name = $jConfig.parameters.hubName.value
            }
            else {
                $name = $jResourceTemplate.parameters.hubName.defaultValue
            }

            $resourceGroupName = "$($namePrefix)-$($name)-rg"
            New-AzResourceGroup -Name $resourceGroupName -Location $resourceLocation -Force
            New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $resourceTemplateFile -TemplateParameterFile $resourceTemplateParameterFile
        }
    }
}

# MAIN

$ErrorActionPreference = "Stop"

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
New-Item -ItemType Directory -Force -Path $tempPath

if ($null -ne $namePrefix -and "" -ne $namePrefix) {
    $jConfig.parameters.namePrefix.value = $namePrefix
}

foreach ($policy in $jConfig.policies) {
    if ($policy.enabled -eq $true) {
        Write-Host "===== Start: Assigning policy '$($policyAssignmentPrefix)$($policy.name)'... ====="
        New-PolicyAssignment -artifact "$($artifactsPath)/$($policy.artifact)"
        Write-Host "===== End: Assigning policy '$($policyAssignmentPrefix)$($policy.name)'... ====="
    }    
}

foreach ($resource in $jConfig.resources) {
    if ($resource.enabled -eq $true) {
        if ($resource.artifact.EndsWith(".json")) {
            Write-Host "===== Start: Deploying resource '$($resource.artifact)' ====="
            New-ResourceDeployment -artifact "$($artifactsPath)/$($resource.artifact)"
            Write-Host "===== End: Deploying resource '$($resource.artifact)' ====="
        }
        elseif ($resource.artifact.EndsWith(".ps1")) {
            Write-Host "===== Start: Executing script '$($resource.artifact)' ====="
            & "$($artifactsPath)/$($resource.artifact)" -namePrefix $jConfig.parameters.namePrefix.value -hubName $($jConfig.parameters.hubName.value) -location $resourceLocation
            Write-Host "===== End: Executing script '$($resource.artifact)' ====="
        }
        else {
            Write-Host "===== Error: Invalid artifact type '$($resource.artifact)' ====="
        }
    }    
}