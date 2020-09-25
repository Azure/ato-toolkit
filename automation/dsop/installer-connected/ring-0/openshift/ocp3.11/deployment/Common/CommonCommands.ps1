function Run-Command
{
    <#
    .SYNOPSIS
    Run-Command runs the specified process with passed arguments and captures the output

    .DESCRIPTION
    Run-Command runs the specified process with passed arguments and captures the output

    .INPUTS
    None. You cannot pipe objects to Run-Command

    .OUTPUTS
    System.Int. Run-Command returns the exit code of the process

    .EXAMPLE
    Basic robocopy command
    $args = "c:\source\ c:\dest\ *.* /Z /MT:4"
    $exitCode = Run-Command -Process "robocopy.exe" -Arguments $args

    .EXAMPLE
    Ping command
    $args = "1.2.3.4"
    $exitCode = Run-Command -Process "ping.exe" -Arguments $args
    #>

    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        #Name of the process to run
        [string]$Process,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        #Arguments separated by spaces
        [string]$Arguments
    )

    try
    {
        ## Need to run application in cmd and get output.  Really a hack to get
        ## non-exe files to run with System.Diagnostics.Process.  If other OS,
        ## this is not a problem.
        if ($IsWindows)
        {
            Log-Information "Running command on a Windows OS. Making modification to launch parameters"
            $Arguments = "/c $Process $Arguments"
            $Process = "cmd.exe"
        }

        Log-Information "Executing $Process $Arguments"

        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $Process
        $pinfo.RedirectStandardError = $true
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = $Arguments
        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo = $pinfo
        $proc.Start() | Out-Null

        $sb = New-Object System.Text.StringBuilder
        $errorStream = New-Object System.Text.StringBuilder

        while(($output = $proc.StandardOutput.Readline()) -ne $null)
        {
            Log-CommandOutput $output
            $sb.AppendLine($output) | Out-Null
        }
        $proc.WaitForExit()
        $errorStream = $proc.StandardError.ReadToEnd()

        if([string]::IsNullOrEmpty($sb.ToString()))
        {
            if (-not [string]::IsNullOrEmpty($errorStream))
            {
                Log-Error "$Process had errors with:`n$errorStream"
            }
            else
            {
                Log-Information "$Process had no output."
            }
        }
    }
    catch
    {
        Log-Error "$_"
    }

    return $($proc.ExitCode)
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Size
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function Get-RandomString
{
    param (
        [int] $Size = 5,
        [switch] $IncludeNumber
    )

    return -join ((65..90) + (97..122) | Get-Random -Count $Size | `
        ForEach-Object {
            $letter = [char]$_
            if ($IncludeNumber)
            {
                Get-Random -InputObject @($letter, (Get-Random -Count 1 -Minimum 0 -Maximum 9))
            }
            else
            {
                $letter
            }
        })
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER ScriptPath
Parameter description

.PARAMETER ScriptFileName
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>

function New-Base64EncodedJson
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptPath,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ScriptFileName
    )
    $scriptContent = ((Get-Content "$ScriptPath/$ScriptFileName") -join "`n")

    # Convert to Base64
    $encodedScript = Get-Base64EncodedString -StringToEncode $scriptContent

    # write to temp json file
    $jsonFile = "$ScriptPath/$ScriptFileName.json"
    Set-Content -Path $jsonFile -Value "{`"script`": `"$encodedScript`"}" | Out-Null

    return $jsonFile
}

<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER StringToEncode
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-Base64EncodedString
{
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$StringToEncode
    )

    $stringInBytes = [System.Text.Encoding]::UTF8.GetBytes($StringToEncode)
    $encodedString = [Convert]::ToBase64String($stringInBytes)

    return $encodedString
}
