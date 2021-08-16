$jConfig = Get-Content "./run.config.json" | ConvertFrom-Json

$tempPath = $jConfig.args.tempPath
$policyTemplate = $jConfig.args.policyTemplate
$artifactsPath = $jConfig.args.artifactsPath
$policyAssignmentPrefix = $jConfig.args.policyAssignmentPrefix
$onlyGenerateTemplates = $jConfig.args.onlyGenerateTemplates
$deploymentUserObjectIdParameterName = "deployment-user-object-id"

$resourceLocation = $jConfig.parameters.location.value
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
                $templateParameters[$paramName] = $jConfig.parameters.$($name)
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
    if ($null -eq $jArtifact.properties.template) {
        Write-Host "Artifact '$($artifact)' does not contain a valid resource template. Skipping..."
        return
    }

    $jResourceTemplate = $jArtifact.properties.template
    foreach ($param in $jArtifact.properties.parameters.psobject.properties) {
        $defaultParamValues = Get-DefaultParameterValues -paramName $param.name -paramNames $param.value -jDefaultParams $jDefaultParams
        $jResourceTemplate.parameters.$($param.name) = $defaultParamValues[$param.name]
    }

    $resourceTemplateFile = "$($tempPath)/resource.$($jArtifact.name).json"
    $jResourceTemplate | ConvertTo-Json -Depth 100 | Set-Content $resourceTemplateFile -Force
    $resourceTemplateParameterFile = "$($tempPath)/resource.$($jArtifact.name).parameters.json"
    Get-TemplateParameters -jParameters $jResourceTemplate.parameters -jConfig $jConfig | ConvertTo-Json -Depth 100 | Set-Content $resourceTemplateParameterFile -Force
    
    if ($onlyGenerateTemplates -eq $false) {
        if ($jResourceTemplate.'$schema'.EndsWith("subscriptionDeploymentTemplate.json#")) {
            New-AzDeployment -Location $resourceLocation -TemplateFile $resourceTemplateFile -TemplateParameterFile $resourceTemplateParameterFile
        }
        else {
            $resourceGroupName = "$($jConfig.parameters.resourcePrefix.value)-sharedsvcs-rg"
            New-AzResourceGroup -Name $resourceGroupName -Location $resourceLocation -Force
            New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $resourceTemplateFile -TemplateParameterFile $resourceTemplateParameterFile
        }
    }
}

# MAIN

$ErrorActionPreference = "Stop"

Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"
New-Item -ItemType Directory -Force -Path $tempPath

foreach ($policy in $jConfig.policies) {
    if ($policy.enabled -eq $true) {
        Write-Host "===== Start: Assigning policy '$($policyAssignmentPrefix)$($policy.name)'... ====="
        New-PolicyAssignment -artifact "$($artifactsPath)/$($policy.artifact)"
        Write-Host "===== End: Assigning policy '$($policyAssignmentPrefix)$($policy.name)'... ====="
    }    
}

foreach ($resource in $jConfig.resources) {
    if ($resource.enabled -eq $true) {
        Write-Host "===== Start: Deploying resource '$($resource.name)' ====="
        New-ResourceDeployment -artifact "$($artifactsPath)/$($resource.artifact)"
        Write-Host "===== End: Deploying resource '$($resource.name)' ====="
    }    
}