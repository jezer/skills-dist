param(
    [Parameter(Mandatory = $true)][string]$Empresa,
    [Parameter(Mandatory = $true)][string]$Usuario,
    [Parameter(Mandatory = $true)][string]$Titulo,
    [string]$Projeto,
    [switch]$Json
)

# Plano 000134 do all_IA (caso 3-A): CHAMADOS 100% NO BANCO - este script e
# CLIENTE da API do all_IA e NAO cria mais arquivos fisicos. A arvore antiga
# em C:\codes\tools\chamados\chamados e LEGADO somente leitura.
# OFFLINE (caso 6-A): a criacao vai para a fila local em
# C:\codes\plan\.fila-pendente e e aplicada quando o backend voltar.

$ErrorActionPreference = "Stop"

$empresas = @("pv", "syg", "cnu", "theo", "elohim", "skills", "tools")
$usuarios = @("jz", "jf")

$empresaNorm = $Empresa.ToLowerInvariant()
$usuarioNorm = $Usuario.ToLowerInvariant()
$tituloNorm = $Titulo.Trim()

if ($empresas -notcontains $empresaNorm) { throw "Empresa invalida: $Empresa" }
if ($usuarios -notcontains $usuarioNorm) { throw "Usuario invalido: $Usuario" }
if ([string]::IsNullOrWhiteSpace($tituloNorm)) { throw "Titulo obrigatorio." }

$apiBase = if ($env:ALLIA_API_URL) { $env:ALLIA_API_URL } else { "http://localhost:8000" }
$payload = @{ empresa = $empresaNorm; usuario = $usuarioNorm; titulo = $tituloNorm }
if ($Projeto) { $payload.projeto = $Projeto }
$payload.conteudo = @'
## Proximo passo obrigatorio

1. Executar a skill `route-skills-by-context` imediatamente apos a criacao deste chamado.
2. Registrar a sessao inicial com `register-ticket-session` usando `route-skills-by-context` como skill executora inicial.

## Historico resumido

1. Criacao do chamado.
'@

try {
    $resp = Invoke-RestMethod -Method Post -Uri "$apiBase/chamados" `
        -ContentType "application/json; charset=utf-8" `
        -Body ([System.Text.Encoding]::UTF8.GetBytes(($payload | ConvertTo-Json -Depth 4))) -TimeoutSec 30
    $resultado = [pscustomobject]@{
        Chamado = $resp.codigo
        Origem  = "api-banco"
        ProximaSkillObrigatoria = "route-skills-by-context"
    }
} catch {
    # fila offline (JSONL) - drenada no startup do backend ou /plans/fila/drenar
    $filaDir = "C:\codes\plan\.fila-pendente"
    if (-not (Test-Path -LiteralPath $filaDir)) { New-Item -ItemType Directory -Path $filaDir -Force | Out-Null }
    $arquivo = Join-Path $filaDir ("{0}-{1}.jsonl" -f (Get-Date -Format "yyyyMMdd-HHmmss-fff"), (Get-Random -Maximum 9999))
    $linha = (@{ op = "criar-chamado"; payload = $payload } | ConvertTo-Json -Depth 6 -Compress)
    [System.IO.File]::WriteAllText($arquivo, $linha + "`n", (New-Object System.Text.UTF8Encoding($false)))
    $resultado = [pscustomobject]@{
        Chamado = "(enfileirado offline - codigo definido na drenagem)"
        Origem  = "fila-offline"
        Fila    = $arquivo
        ProximaSkillObrigatoria = "route-skills-by-context"
    }
}

if ($Json) { $resultado | ConvertTo-Json -Compress } else { $resultado }
