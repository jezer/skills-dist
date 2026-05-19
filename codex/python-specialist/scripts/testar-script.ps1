param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [string[]]$Args = @()
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Script nao encontrado: $ScriptPath"
}

& python $ScriptPath @Args
$exitCode = $LASTEXITCODE

[pscustomobject]@{
    Script = $ScriptPath
    ExitCode = $exitCode
    Ok = ($exitCode -eq 0)
}
