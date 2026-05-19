param(
    [Parameter(Mandatory = $true)][string]$ScriptPath,
    [string[]]$Args = @()
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ScriptPath)) {
    throw "Script nao encontrado: $ScriptPath"
}

$null = [System.Management.Automation.PSParser]::Tokenize((Get-Content -LiteralPath $ScriptPath -Raw), [ref]$null)

& powershell -NoProfile -ExecutionPolicy Bypass -File $ScriptPath @Args
$exitCode = $LASTEXITCODE

[pscustomobject]@{
    Script = $ScriptPath
    ExitCode = $exitCode
    Ok = ($exitCode -eq 0)
}
