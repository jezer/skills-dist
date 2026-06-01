param(
    [string]$Database = "ai_platform",
    [string]$User = "ai_admin",
    [string]$HostName = "localhost",
    [int]$Port = 5432,
    [string]$OutputDir = "C:\backup\postgresql",
    [string]$PgDumpPath = "pg_dump",
    [datetime]$Date = (Get-Date),
    [switch]$DryRun,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$slotScript = Join-Path $PSScriptRoot "get-backup-slot.ps1"
$slot = & $slotScript -Date $Date -Prefix $Database
$files = @($slot.Files)
$results = @()

if (-not $DryRun -and -not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

foreach ($file in $files) {
    $target = Join-Path $OutputDir $file.FileName
    $arguments = @(
        "-h", $HostName,
        "-p", [string]$Port,
        "-U", $User,
        "-Fc",
        "-f", $target,
        $Database
    )

    if ($DryRun) {
        $exitCode = $null
        $executed = $false
    } else {
        & $PgDumpPath @arguments
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0) {
            throw "pg_dump failed for $target with exit code $exitCode"
        }
        $executed = $true
    }

    $results += [pscustomobject]@{
        Cycle = $file.Cycle
        Slot = $file.Slot
        Target = $target
        Executed = $executed
        ExitCode = $exitCode
    }
}

$result = [pscustomobject]@{
    Date = $Date.ToString("yyyy-MM-dd")
    Database = $Database
    OutputDir = $OutputDir
    DryRun = [bool]$DryRun
    Results = $results
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result
}
