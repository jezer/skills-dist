param(
    [string]$Repositorio = ".",
    [switch]$Pull = $true,
    [switch]$Push = $true
)

$ErrorActionPreference = "Stop"

function Invoke-GitSafe {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )
    & git "-c" "safe.directory=$RepoPath" @GitArgs
}

function Get-ConvencoesPath {
    param([string]$Repositorio)
    $raiz = (Resolve-Path -LiteralPath $Repositorio).Path
    return (Join-Path $raiz "git-convencoes.md")
}

function Get-ModeloRepositorio {
    param([string]$Repositorio)
    $scriptPath = Join-Path $PSScriptRoot "detectar-modelo-repositorio.ps1"
    if (-not (Test-Path -LiteralPath $scriptPath)) { return "indefinido" }
    $res = & $scriptPath -Repositorio $Repositorio
    return $res.ModeloRepositorio
}

$repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
$branch = (Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "branch", "--show-current")).Trim()
$statusAntes = Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "status", "--short")

if ($Push -and @("main", "master") -contains $branch) {
    throw "Push bloqueado na branch '$branch'. Crie uma branch de trabalho antes de sincronizar."
}

if ($Pull) {
    Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "pull")
}

if ($Push) {
    Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "push")
}

$statusDepois = Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "status", "--short")

[pscustomobject]@{
    Repositorio = $repoPath
    Branch = $branch
    Pull = [bool]$Pull
    Push = [bool]$Push
    StatusAntes = ($statusAntes -join "; ")
    StatusDepois = ($statusDepois -join "; ")
    Convencoes = (Get-ConvencoesPath -Repositorio $Repositorio)
    ModeloRepositorio = (Get-ModeloRepositorio -Repositorio $Repositorio)
}
