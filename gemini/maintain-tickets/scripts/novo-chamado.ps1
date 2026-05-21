param(
    [Parameter(Mandatory = $true)][string]$Empresa,
    [Parameter(Mandatory = $true)][string]$Usuario,
    [Parameter(Mandatory = $true)][string]$Titulo,
    [int]$Ano = (Get-Date).Year,
    [string]$BasePath = "C:\codes\tools\chamados\chamados",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$empresas = @("pv", "syg", "cnu", "theo", "elohim", "skills", "tools")
$usuarios = @("jz", "jf")

$empresaNorm = $Empresa.ToLowerInvariant()
$usuarioNorm = $Usuario.ToLowerInvariant()
$tituloNorm = $Titulo.Trim()

if ($empresas -notcontains $empresaNorm) {
    throw "Empresa invalida: $Empresa"
}

if ($usuarios -notcontains $usuarioNorm) {
    throw "Usuario invalido: $Usuario"
}

if ([string]::IsNullOrWhiteSpace($tituloNorm)) {
    throw "Titulo obrigatorio."
}

$anoPath = Join-Path $BasePath (Join-Path $empresaNorm (Join-Path $usuarioNorm $Ano))
if (-not (Test-Path -LiteralPath $anoPath)) {
    New-Item -ItemType Directory -Path $anoPath | Out-Null
}

$sequenciais = Get-ChildItem -LiteralPath $anoPath -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{5}$' } |
    ForEach-Object { [int]$_.Name }

$proximo = 1
if ($sequenciais) {
    $proximo = (($sequenciais | Measure-Object -Maximum).Maximum + 1)
}

$seq = $proximo.ToString("00000")
$id = "$($empresaNorm.ToUpperInvariant())-$($usuarioNorm.ToUpperInvariant())-CH-$Ano-$seq"
$chamadoPath = Join-Path $anoPath $seq
$pendentesPath = Join-Path $chamadoPath "sessoes\pendentes"
$feitasPath = Join-Path $chamadoPath "sessoes\feitas"

New-Item -ItemType Directory -Path $pendentesPath -Force | Out-Null
New-Item -ItemType Directory -Path $feitasPath -Force | Out-Null

$data = Get-Date -Format "yyyy-MM-dd"
# Cabecalho com interpolacao (double-quoted here-string)
$cabecalho = @"
# $id - $tituloNorm

- Empresa: $empresaNorm
- Usuario atual: $usuarioNorm
- Ano: $Ano
- Sequencial anual: $seq
- Titulo: $tituloNorm
- Status: aberto
- Criado em: $data
- Atualizado em: $data
- Sessoes pendentes: sessoes/pendentes/
- Sessoes feitas: sessoes/feitas/

## Objetivo

Definir e acompanhar o chamado $id.

## Proximo passo obrigatorio

"@
# Bloco literal com backticks (single-quoted here-string nao processa escapes)
$bloco = @'
1. Executar a skill `route-skills-by-context` imediatamente apos a criacao deste chamado.
2. Registrar a sessao inicial com `register-ticket-session` usando `route-skills-by-context` como skill executora inicial.

## Historico resumido

1. Criacao do chamado.
'@
$conteudo = $cabecalho + $bloco

$chamadoFile = Join-Path $chamadoPath "chamado.md"
Set-Content -LiteralPath $chamadoFile -Value $conteudo -Encoding UTF8

$resultado = [pscustomobject]@{
    Chamado = $id
    Caminho = $chamadoPath
    Arquivo = $chamadoFile
    ProximaSkillObrigatoria = "route-skills-by-context"
}

if ($Json) {
    $resultado | ConvertTo-Json -Compress
} else {
    $resultado
}

