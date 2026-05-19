param(
    [ValidateSet("feature", "fix", "docs", "chore", "refactor", "test")][string]$Tipo,
    [string]$Descricao,
    [string]$Escopo,
    [string]$Chamado,
    [string]$Repositorio = ".",
    [switch]$Criar
)

$ErrorActionPreference = "Stop"

function Invoke-GitSafe {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )
    & git "-c" "safe.directory=$RepoPath" @GitArgs
}

function Resolve-RespostaSim {
    param([string]$Valor)
    if ($null -eq $Valor) { return $false }
    return ($Valor.Trim().ToLowerInvariant() -match '^(s|sim|y|yes)$')
}

function Get-ConvencoesPath {
    param([string]$Repositorio)
    $raiz = (Resolve-Path -LiteralPath $Repositorio).Path
    return (Join-Path $raiz "git-convencoes.md")
}

if (-not $Tipo) {
    $Tipo = (Read-Host "Tipo de branch (feature, fix, docs, chore, refactor, test)").Trim().ToLowerInvariant()
}
if (-not @("feature", "fix", "docs", "chore", "refactor", "test").Contains($Tipo)) {
    throw "Tipo invalido: $Tipo"
}

if (-not $Descricao) {
    $Descricao = Read-Host "Descricao curta da branch"
}

$Descricao = $Descricao.Trim()
if (-not $Descricao) {
    throw "Descricao vazia."
}

if (-not $PSBoundParameters.ContainsKey("Criar")) {
    $Criar = Resolve-RespostaSim (Read-Host "Criar branch agora? [s/N]")
}

$partes = @()
if ($Escopo -and ($Descricao -notlike "*$Escopo*")) { $partes += $Escopo }
if ($Chamado) { $partes += $Chamado }
$partes += $Descricao

$nome = (($partes -join "-").ToLowerInvariant() -replace '[^a-z0-9-]', '-').Trim('-')
$branch = "$Tipo/$nome"

if ($Criar) {
    $repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
    $temCommit = $true
    try {
        Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "rev-parse", "--verify", "HEAD") *> $null
    } catch {
        $temCommit = $false
    }

    if ($LASTEXITCODE -ne 0) {
        $temCommit = $false
    }

    if ($temCommit) {
        $status = Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "status", "--porcelain")
        if ($status) {
            throw "Repositorio possui alteracoes pendentes. Revise antes de criar branch."
        }
    }

    Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "checkout", "-b", $branch)
}

[pscustomobject]@{
    Branch = $branch
    Criada = [bool]$Criar
    Convencoes = (Get-ConvencoesPath -Repositorio $Repositorio)
}
