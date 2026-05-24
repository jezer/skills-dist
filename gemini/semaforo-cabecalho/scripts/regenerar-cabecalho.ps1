param(
    [string]$Versao = "v3.0",
    [string]$ConfigOverride
)

$config    = if ($ConfigOverride) { $ConfigOverride } else { "C:\codes\skills\domains\products\semaforo-cabecalho\config\semaforo.json" }
$builder   = "C:\codes\skills\generators\code-parquet-builder\scripts\build-code-parquet.ps1"

if (-not (Test-Path $config)) {
    Write-Error "Config nao encontrada: $config"
    exit 1
}
if (-not (Test-Path $builder)) {
    Write-Error "code-parquet-builder nao encontrado: $builder"
    exit 1
}

Write-Host "semaforo-cabecalho: regenerando parquet versao=$Versao via code-parquet-builder"
& $builder -Config $config -Versao $Versao
