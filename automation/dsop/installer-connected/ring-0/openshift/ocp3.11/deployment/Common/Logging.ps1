$Global:Logging = @{}
$Global:Logging.ScriptStartTime = $null
$Global:Logging.LogFile = "$($Env:TMP)\$($MyInvocation.MyCommand)_$(Get-Date -format MM-dd-yyyy-hhmmss).log"

function Start-Logging ($Message)
{
    if (($Global:Logging.LogFile -match "(\/|\\)") -and (-not (Test-Path ([io.path]::GetDirectoryName($Global:Logging.LogFile)))))
    {
        New-Item ([io.path]::GetDirectoryName($Global:Logging.LogFile)) -ItemType Directory | Out-Null
    }

    if(-not (Test-Path $Global:Logging.LogFile))
    {
        New-Item $Global:Logging.LogFile -ItemType File | Out-Null
    }

    Log-WriteMessage -Message $Message -fgColor "Green"
}

function Set-LogFile {
    param (
        [Parameter(Position=1,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$LogFile
    )
    $Global:Logging.LogFile = $LogFile
}

function Log-WriteMessage
{
    param
    (
        [parameter(Mandatory=$True, Position=0)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Message,

        [parameter(Mandatory=$False, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$fgColor = "White"
    )

    Write-Host $Message -ForegroundColor $fgColor
    Add-Content -Path $Global:Logging.LogFile -Value "[$(Get-Date -format "MM/dd/yyyy HH:mm:ss")] $Message"
}

function Log-Information
{
    param
    (
        [parameter(Mandatory=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Message
    )

    $fullMessage = "[Information] $Message"
    Log-WriteMessage -Message $fullMessage
}

function Log-Error
{
    param
    (
        [parameter(Mandatory=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Message
    )

    $fullMessage = "[Error] $Message"
    Log-WriteMessage -Message $fullMessage -fgColor Red
}

function Log-Warning
{
    param
    (
        [parameter(Mandatory=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Message
    )

    $fullMessage = "[Warning] $Message"
    Log-WriteMessage -Message $fullMessage -fgColor Yellow
}

function Log-CommandOutput
{
    param
    (
        [parameter(Mandatory=$true)]
        [AllowNull()]
        [AllowEmptyString()]
        [string]$Message
    )

    $fullMessage = "[Command Output] $Message"
    Log-WriteMessage -Message $fullMessage -fgColor Gray
}

function Log-ScriptHeader
{
    param
    (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$ScriptName,

        [Parameter(Position=1,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$LogFile = $Global:Logging.LogFile,

        [Parameter(Position=2,Mandatory=$False,ValueFromRemainingArguments=$True)]
        $scriptArgs
    )

    Set-LogFile $LogFile
    $Global:Logging.ScriptStartTime = Get-Date

    $sb = New-Object System.Text.StringBuilder
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null
    $sb.AppendLine("= Running $ScriptName") | Out-Null
    $sb.AppendLine("= Start Time: $($Global:Logging.ScriptStartTime)") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null

    foreach($kvp in $scriptArgs)
    {
        $extraParams = $False
        foreach($key in $kvp.Keys)
        {
            if($key -match "[Pp]assword" -or $key -match "RawSshKey")
            {
                $sb.AppendLine("= Using -$key = **REDACTED**") | Out-Null
            }
            else
            {
                $val = (Get-Variable -Name $key -ErrorAction SilentlyContinue).Value
                if ($val.length -gt 0)
                {
                    $sb.AppendLine("= Using -$key = $val") | Out-Null
                }
            }

            $extraParams = $True
        }
    }
    if($extraParams)
    {
        $sb.AppendLine("==============================================") | Out-Null
    }

    Start-Logging $sb.ToString()
}

function Log-Parameters
{
    param
    (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$ScriptName,

        [Parameter(Position=1,Mandatory=$False,ValueFromRemainingArguments=$True)]
        $scriptArgs
    )
    $sb = New-Object System.Text.StringBuilder
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null
    $sb.AppendLine("= Running $ScriptName") | Out-Null
    $sb.AppendLine("= Start Time: $(Get-Date)") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null

    foreach($kvp in $scriptArgs)
    {
        foreach($key in $kvp.Keys)
        {
            if($key -match "RawSshKey")
            {
                $sb.AppendLine("= Using -$key = **REDACTED**") | Out-Null
            }
            if($key -match "[Pp]assword" -or $key -match "RawSshKey")
            {
                $sb.AppendLine("= Using -$key = **REDACTED**") | Out-Null
            }
            else
            {
                $val = (Get-Variable -Name $key -ErrorAction SilentlyContinue).Value
                if ($val.length -gt 0)
                {
                    $sb.AppendLine("= Using -$key = $val") | Out-Null
                }
            }
        }
    }
    $sb.AppendLine("==============================================") | Out-Null

    Log-WriteMessage -Message $sb.ToString() -fgColor Green
}

function Log-ScriptEnd
{
    $sb = New-Object System.Text.StringBuilder
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null
    $sb.AppendLine("= Script End") | Out-Null
    $sb.AppendLine("= Log file located at: $($Global:Logging.LogFile)") | Out-Null
    $sb.AppendLine("= End Time: $(Get-Date)") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null

    Log-WriteMessage -Message $sb.ToString() -fgColor Green
}

function Log-Footer
{
    param
    (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$ScriptName
    )

    $sb = New-Object System.Text.StringBuilder
    $sb.AppendLine("") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null
    $sb.AppendLine("= $ScriptName End") | Out-Null
    $sb.AppendLine("= End Time: $(Get-Date)") | Out-Null
    $sb.AppendLine("==============================================") | Out-Null

    Log-WriteMessage -Message $sb.ToString() -fgColor Green
}
