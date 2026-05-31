param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$Destino,
    [string]$BasePath,
    [string]$Pasta,
    [Parameter(Mandatory = $true)][string]$Branch,
    [int]$Depth,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Invoke-GitSafe {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )
    & git "-c" "safe.directory=$RepoPath" @GitArgs
}

function Get-DefaultFolderName {
    param([string]$RepoUrl)
    $clean = ($RepoUrl.TrimEnd('/') -split '/')[-1]
    if ($clean.EndsWith(".git")) {
        return $clean.Substring(0, $clean.Length - 4)
    }
    return $clean
}

if ([string]::IsNullOrWhiteSpace($Url)) {
    throw "URL obrigatoria."
}

$urlNorm = $Url.Trim()
$branchNorm = $Branch.Trim()
if ([string]::IsNullOrWhiteSpace($branchNorm)) {
    throw "Branch obrigatoria. Informe explicitamente a branch de trabalho antes de clonar."
}

$folderName = if ($Pasta) { $Pasta.Trim() } else { Get-DefaultFolderName -RepoUrl $urlNorm }
if ([string]::IsNullOrWhiteSpace($folderName)) {
    throw "Nao foi possivel definir o nome da pasta de destino."
}

if ($Destino) {
    $targetPath = $Destino
} elseif ($BasePath) {
    $targetPath = Join-Path $BasePath $folderName
} else {
    throw "Informe -Destino ou -BasePath."
}

$targetPath = [System.IO.Path]::GetFullPath($targetPath)

if (Test-Path -LiteralPath $targetPath) {
    $items = Get-ChildItem -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
    if ($items.Count -gt 0) {
        throw "Destino ja existe e nao esta vazio: $targetPath"
    }
}

$args = @("clone", "--branch", $branchNorm)
if ($Depth -gt 0) {
    $args += @("--depth", $Depth)
}
$args += @($urlNorm, $targetPath)

if ($DryRun) {
    [pscustomobject]@{
        Url = $urlNorm
        Destino = $targetPath
        Branch = $branchNorm
        Depth = $Depth
        Executado = $false
    }
    return
}

& git "-c" "safe.directory=$targetPath" @args | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Falha ao clonar repositorio: $urlNorm"
}

if (-not (Test-Path -LiteralPath (Join-Path $targetPath ".git"))) {
    throw "Clone nao concluido corretamente: $targetPath"
}

$branchAtual = (Invoke-GitSafe -RepoPath $targetPath -GitArgs @("-C", $targetPath, "branch", "--show-current") | Out-String).Trim()
if ($branchAtual -ne $branchNorm) {
    throw "Clone concluido em branch inesperada. Esperado: '$branchNorm'. Atual: '$branchAtual'."
}

[pscustomobject]@{
    Url = $urlNorm
    Destino = $targetPath
    Branch = $branchAtual
    Depth = $Depth
    Origin = ((Invoke-GitSafe -RepoPath $targetPath -GitArgs @("-C", $targetPath, "remote", "get-url", "origin") | Out-String).Trim())
    Executado = $true
}
