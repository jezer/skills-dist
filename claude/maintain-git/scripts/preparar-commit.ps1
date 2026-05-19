param(
    [ValidateSet("feature", "fix", "docs", "chore", "refactor", "test")][string]$Tipo,
    [string]$Escopo,
    [string]$Resumo,
    [string]$Chamado,
    [string]$Corpo,
    [string]$Repositorio = "."
)

$ErrorActionPreference = "Stop"

function Get-ConvencoesPath {
    param([string]$Repositorio)
    $raiz = (Resolve-Path -LiteralPath $Repositorio).Path
    return (Join-Path $raiz "git-convencoes.md")
}

if (-not $Tipo) {
    $Tipo = (Read-Host "Tipo de commit (feature, fix, docs, chore, refactor, test)").Trim().ToLowerInvariant()
}
if (-not @("feature", "fix", "docs", "chore", "refactor", "test").Contains($Tipo)) {
    throw "Tipo invalido: $Tipo"
}

if (-not $Escopo) {
    $Escopo = Read-Host "Escopo do commit"
}
if (-not $Resumo) {
    $Resumo = Read-Host "Resumo curto do commit"
}

$escopoNorm = ($Escopo.ToLowerInvariant() -replace '[^a-z0-9-]', '-').Trim('-')
$resumoNorm = $Resumo.Trim()
if (-not $escopoNorm) {
    throw "Escopo normalizado vazio."
}
if (-not $resumoNorm) {
    throw "Resumo vazio."
}
$mensagem = "$Tipo($escopoNorm): $resumoNorm"

if ($Chamado -or $Corpo) {
    $linhas = @($mensagem, "")
    if ($Corpo) {
        $linhas += $Corpo
        $linhas += ""
    }
    if ($Chamado) {
        $linhas += "Chamado: $Chamado"
    }
    $mensagem = $linhas -join [Environment]::NewLine
}

[pscustomobject]@{
    Mensagem = $mensagem
    Convencoes = (Get-ConvencoesPath -Repositorio $Repositorio)
}
