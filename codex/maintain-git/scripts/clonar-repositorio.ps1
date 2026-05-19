param(
    [Parameter(Mandatory = $true)][string]$Url,
    [string]$Destino,
    [string]$BasePath,
    [string]$Pasta,
    [string]$Branch,
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

$args = @("clone", $urlNorm, $targetPath)
if ($Branch) {
    $args += @("--branch", $Branch)
}
if ($Depth -gt 0) {
    $args += @("--depth", $Depth)
}

if ($DryRun) {
    [pscustomobject]@{
        Url = $urlNorm
        Destino = $targetPath
        Branch = $Branch
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

[pscustomobject]@{
    Url = $urlNorm
    Destino = $targetPath
    Branch = if ($Branch) { $Branch } else { (Invoke-GitSafe -RepoPath $targetPath -GitArgs @("-C", $targetPath, "branch", "--show-current") | Out-String).Trim() }
    Depth = $Depth
    Origin = ((Invoke-GitSafe -RepoPath $targetPath -GitArgs @("-C", $targetPath, "remote", "get-url", "origin") | Out-String).Trim())
    Executado = $true
}
