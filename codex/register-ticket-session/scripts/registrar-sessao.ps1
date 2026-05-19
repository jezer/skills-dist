param(
    [Parameter(Mandatory = $true)][string]$Chamado,
    [Parameter(Mandatory = $true)][string]$Titulo,
    [string]$Resumo = "Referencia inicial da sessao.",
    [string]$DataHora = (Get-Date -Format "o"),
    [string]$BasePath = "C:\codes\tools\chamados\chamados",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

if ($Chamado -notmatch '^(?<empresa>[A-Z]+)-(?<usuario>[A-Z]+)-CH-(?<ano>\d{4})-(?<seq>\d{5})$') {
    throw "Formato de chamado invalido: $Chamado"
}

$empresa = $Matches.empresa.ToLowerInvariant()
$usuario = $Matches.usuario.ToLowerInvariant()
$ano = $Matches.ano
$seq = $Matches.seq
$chamadoCanonico = "$($empresa.ToUpperInvariant())-$($usuario.ToUpperInvariant())-CH-$ano-$seq"
$tituloNorm = $Titulo.Trim()

if ([string]::IsNullOrWhiteSpace($tituloNorm)) {
    throw "Titulo obrigatorio."
}

$chamadoPath = Join-Path $BasePath (Join-Path $empresa (Join-Path $usuario (Join-Path $ano $seq)))
$chamadoFile = Join-Path $chamadoPath "chamado.md"

if (-not (Test-Path -LiteralPath $chamadoFile)) {
    throw "chamado.md nao encontrado: $chamadoFile"
}

$pendentesPath = Join-Path $chamadoPath "sessoes\pendentes"
$feitasPath = Join-Path $chamadoPath "sessoes\feitas"
New-Item -ItemType Directory -Path $pendentesPath -Force | Out-Null
New-Item -ItemType Directory -Path $feitasPath -Force | Out-Null

$existentes = @()
foreach ($dir in @($pendentesPath, $feitasPath)) {
    $existentes += Get-ChildItem -LiteralPath $dir -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.BaseName -match '^\d{3}$' } |
        ForEach-Object { [int]$_.BaseName }
}

$proximo = 1
if ($existentes) {
    $proximo = (($existentes | Measure-Object -Maximum).Maximum + 1)
}

$nnn = $proximo.ToString("000")
$hashTexto = "$chamadoCanonico|$empresa|$usuario|$tituloNorm|$DataHora"
$sha = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($hashTexto)
$hash = (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "")

$sessaoId = "SESS-" + ([DateTimeOffset]::Parse($DataHora).ToString("yyyy-MM-dd-HHmmss"))
$arquivo = Join-Path $pendentesPath "$nnn.md"
$conteudo = @"
## $sessaoId - $Chamado

- Chamado: $chamadoCanonico
- Empresa: $empresa
- Usuario atual: $usuario
- Titulo: $tituloNorm
- Data/hora: $DataHora
- Status da sessao: pendente
- Hash: $hash
- Resumo: $Resumo
- Skills candidatas: route-skills-by-context
- Skill executora: route-skills-by-context
- Skills de apoio: PREENCHER
- Motivo da escolha: Primeiro roteamento obrigatorio apos iniciar o chamado.
"@

Set-Content -LiteralPath $arquivo -Value $conteudo -Encoding UTF8

$resultado = [pscustomobject]@{
    Sessao = $nnn
    Arquivo = $arquivo
    Hash = $hash
    Chamado = $chamadoCanonico
}

if ($Json) {
    $resultado | ConvertTo-Json -Compress
} else {
    $resultado
}

