param(
    [Parameter(Mandatory = $true)]
    [string]$SqlOld,

    [Parameter(Mandatory = $true)]
    [string]$SqlNew,

    [string]$LabelOld = "old",
    [string]$LabelNew = "new",

    [string]$PythonExecutable = "python",
    [string]$ComparatorPythonScript = "C:\codes\tools\csv_comparator\compare_sql_rules.py",
    [string]$LogsDir = "C:\codes\tools\csv_comparator\logs_sql_rules",

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SqlOld)) {
    throw "Arquivo SQL antigo nao encontrado: $SqlOld"
}
if (-not (Test-Path -LiteralPath $SqlNew)) {
    throw "Arquivo SQL novo nao encontrado: $SqlNew"
}
if (-not (Test-Path -LiteralPath $ComparatorPythonScript)) {
    throw "Comparador Python nao encontrado: $ComparatorPythonScript"
}

if (-not (Test-Path -LiteralPath $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path $LogsDir ("comparacao_regras_{0}_vs_{1}_{2}.log" -f $LabelOld, $LabelNew, $timestamp)

$cmd = @(
    $ComparatorPythonScript,
    $SqlOld,
    $SqlNew,
    "--label-old", $LabelOld,
    "--label-new", $LabelNew
)

if ($DryRun) {
    [pscustomobject]@{
        DryRun = $true
        PythonExecutable = $PythonExecutable
        ComparatorPythonScript = $ComparatorPythonScript
        SqlOld = $SqlOld
        SqlNew = $SqlNew
        LabelOld = $LabelOld
        LabelNew = $LabelNew
        LogFile = $logFile
    }
    return
}

& $PythonExecutable @cmd | Tee-Object -FilePath $logFile

[pscustomobject]@{
    DryRun = $false
    LogFile = $logFile
    LabelOld = $LabelOld
    LabelNew = $LabelNew
}
