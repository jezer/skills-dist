param(
    [Parameter(Mandatory = $true)][string]$Chamado,
    [Parameter(Mandatory = $true)][string]$Titulo,
    [string]$Resumo = "Referencia inicial da sessao.",
    [string]$DataHora = (Get-Date -Format "o"),
    [switch]$Json
)

# Plano 000134 do all_IA (caso 3-A): SESSOES 100% NO BANCO - cliente da API,
# sem arquivos fisicos novos (arvore antiga = legado somente leitura).
# OFFLINE (caso 6-A): registro vai para a fila local e e drenado depois.

$ErrorActionPreference = "Stop"

if ($Chamado -notmatch '^(?<empresa>[A-Z]+)-(?<usuario>[A-Z]+)-CH-(?<ano>\d{4})-(?<seq>\d{5})$') {
    throw "Formato de chamado invalido: $Chamado"
}
$chamadoCanonico = $Chamado.ToUpperInvariant()
$tituloNorm = $Titulo.Trim()
if ([string]::IsNullOrWhiteSpace($tituloNorm)) { throw "Titulo obrigatorio." }

$hashTexto = "$chamadoCanonico|$tituloNorm|$DataHora"
$sha = [System.Security.Cryptography.SHA256]::Create()
$hash = ((($sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($hashTexto))) | ForEach-Object { $_.ToString("x2") }) -join "")
$sessaoId = "SESS-" + ([DateTimeOffset]::Parse($DataHora).ToString("yyyy-MM-dd-HHmmss"))

$conteudo = @"
## $sessaoId - $chamadoCanonico

- Chamado: $chamadoCanonico
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

$apiBase = if ($env:ALLIA_API_URL) { $env:ALLIA_API_URL } else { "http://localhost:8000" }
$payload = @{ titulo = $tituloNorm; conteudo = $conteudo; estado = "pendente" }

try {
    $resp = Invoke-RestMethod -Method Post -Uri "$apiBase/chamados/$chamadoCanonico/sessoes" `
        -ContentType "application/json; charset=utf-8" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Depth 4))) -TimeoutSec 30
    $resultado = [pscustomobject]@{
        Sessao  = $resp.numero
        Origem  = "api-banco"
        Hash    = $hash
        Chamado = $chamadoCanonico
    }
} catch {
    $filaDir = "C:\codes\plan\.fila-pendente"
    if (-not (Test-Path -LiteralPath $filaDir)) { New-Item -ItemType Directory -Path $filaDir -Force | Out-Null }
    $arquivo = Join-Path $filaDir ("{0}-{1}.jsonl" -f (Get-Date -Format "yyyyMMdd-HHmmss-fff"), (Get-Random -Maximum 9999))
    $payload.codigo = $chamadoCanonico
    $linha = (@{ op = "registrar-sessao"; payload = $payload } | ConvertTo-Json -Depth 6 -Compress)
    [System.IO.File]::WriteAllText($arquivo, $linha + "`n", (New-Object System.Text.UTF8Encoding($false)))
    $resultado = [pscustomobject]@{
        Sessao  = "(enfileirada offline)"
        Origem  = "fila-offline"
        Fila    = $arquivo
        Hash    = $hash
        Chamado = $chamadoCanonico
    }
}

if ($Json) { $resultado | ConvertTo-Json -Compress } else { $resultado }
