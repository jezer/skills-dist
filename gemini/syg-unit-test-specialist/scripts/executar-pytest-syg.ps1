param(
    [string]$Projeto = ".",
    [string]$Alvo = "",
    [switch]$ComCobertura = $false
)

$ErrorActionPreference = "Stop"

$repoPath = (Resolve-Path -LiteralPath $Projeto).Path
$pytestArgs = @("-m", "pytest")

if ($ComCobertura) {
    $pytestArgs += @("--cov", "--cov-report=term-missing")
}

if ($Alvo -and $Alvo.Trim().Length -gt 0) {
    $pytestArgs += @($Alvo)
}

Write-Host "Executando testes em: $repoPath"
Write-Host "Comando: python $($pytestArgs -join ' ')"

Push-Location $repoPath
try {
    & python @pytestArgs
}
finally {
    Pop-Location
}
