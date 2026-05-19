param(
    [Parameter(Mandatory = $true)][string]$Repositorio,
    [string]$Empresa,
    [string]$Nome,
    [string]$BasePath = "C:\codes",
    [ValidateSet("multi-repositorio", "mono-repositorio")][string]$ModeloRepositorio = "mono-repositorio"
)

$ErrorActionPreference = "Stop"

function New-ConvencoesContent {
    param(
        [string]$EmpresaNorm,
        [string]$NomeNorm,
        [string]$BasePathNorm,
        [string]$ModeloNorm
    )

    $template = @'
# Convencoes Git

- Repositorio: __NOME__
- Empresa: __EMPRESA__
- BasePath: __BASEPATH__
- ModeloRepositorio: __MODELO__
- Provedor remoto padrao: github

## Branches

1. Formato recomendado: `tipo/escopo-descricao-curta`.
2. Tipos permitidos: `feature`, `fix`, `docs`, `chore`, `refactor`, `test`.
3. Usar minusculas, numeros e hifens.
4. Incluir chamado quando ajudar rastreabilidade.

## Commits

1. Formato recomendado: `tipo(escopo): resumo curto`.
2. O resumo deve dizer o que mudou.
3. Referenciar chamado no corpo quando aplicavel.
4. Evitar mensagens genericas como `update`, `fix`, `alteracoes` ou `wip`.

## Bootstrap

1. Usar `maintain-git` para criar, preparar e sincronizar este repositorio quando necessario.
2. Conferir `git status` antes de branch, commit, pull, merge, rebase ou push.
3. Nao executar commit ou push na `main`/`master`; criar branch de trabalho antes.
4. Nao executar operacoes destrutivas sem pedido explicito.
'@

    $template = $template.Replace('__NOME__', $NomeNorm)
    $template = $template.Replace('__EMPRESA__', $EmpresaNorm)
    $template = $template.Replace('__BASEPATH__', $BasePathNorm)
    $template = $template.Replace('__MODELO__', $ModeloNorm)
    return $template
}

$repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
if (-not $Empresa) {
    $Empresa = Split-Path -Leaf (Split-Path -Path $repoPath -Parent)
}
if (-not $Nome) {
    $Nome = Split-Path -Leaf $repoPath
}

$empresaNorm = $Empresa.ToLowerInvariant()
$nomeNorm = $Nome.ToLowerInvariant()
$convencoesPath = Join-Path $repoPath "git-convencoes.md"
Set-Content -LiteralPath $convencoesPath -Value (New-ConvencoesContent -EmpresaNorm $empresaNorm -NomeNorm $nomeNorm -BasePathNorm $BasePath -ModeloNorm $ModeloRepositorio) -Encoding utf8

[pscustomobject]@{
    Repositorio = $repoPath
    Convencoes = $convencoesPath
    Empresa = $empresaNorm
    Nome = $nomeNorm
    ModeloRepositorio = $ModeloRepositorio
}

