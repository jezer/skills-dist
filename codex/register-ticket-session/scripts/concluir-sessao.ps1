param(
    [Parameter(Mandatory = $true)][string]$Chamado,
    [Parameter(Mandatory = $true)][string]$Titulo,
    [Parameter(Mandatory = $true)][string]$Resumo,
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

$chamadoPath = Join-Path $BasePath (Join-Path $empresa (Join-Path $usuario (Join-Path $ano $seq)))
$pendentesPath = Join-Path $chamadoPath "sessoes\pendentes"
$feitasPath = Join-Path $chamadoPath "sessoes\feitas"
New-Item -ItemType Directory -Path $feitasPath -Force | Out-Null

# Descobre o maior NNN entre pendentes e feitas
$existentes = @()
foreach ($dir in @($pendentesPath, $feitasPath)) {
    if (Test-Path -LiteralPath $dir) {
        $existentes += Get-ChildItem -LiteralPath $dir -Filter "*.md" -ErrorAction SilentlyContinue |
            Where-Object { $_.BaseName -match '^\d{3}$' } |
            ForEach-Object { [int]$_.BaseName }
    }
}

$hashTexto = "$chamadoCanonico|$empresa|$usuario|$($Titulo.Trim())|$DataHora"
$sha = [System.Security.Cryptography.SHA256]::Create()
$bytes = [System.Text.Encoding]::UTF8.GetBytes($hashTexto)
$hash = (($sha.ComputeHash($bytes) | ForEach-Object { $_.ToString("x2") }) -join "")
$sessaoId = "SESS-" + ([DateTimeOffset]::Parse($DataHora).ToString("yyyy-MM-dd-HHmmss"))

# Tenta mover sessao pendente existente; se nao houver, cria diretamente em feitas
$pendente = if (Test-Path -LiteralPath $pendentesPath) {
    Get-ChildItem -LiteralPath $pendentesPath -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.BaseName -match '^\d{3}$' } |
        Sort-Object Name | Select-Object -Last 1
} else { $null }

if ($pendente) {
    $nnn = $pendente.BaseName
    $destino = Join-Path $feitasPath "$nnn.md"
    $conteudo = @"
## $sessaoId - $chamadoCanonico

- Chamado: $chamadoCanonico
- Empresa: $empresa
- Usuario atual: $usuario
- Titulo: $($Titulo.Trim())
- Data/hora: $DataHora
- Status da sessao: feita
- Hash: $hash
- Resumo: $($Resumo.Trim())
"@
    Set-Content -LiteralPath $destino -Value $conteudo -Encoding UTF8
    Remove-Item -LiteralPath $pendente.FullName
} else {
    $proximo = if ($existentes) { (($existentes | Measure-Object -Maximum).Maximum + 1) } else { 1 }
    $nnn = $proximo.ToString("000")
    $destino = Join-Path $feitasPath "$nnn.md"
    $conteudo = @"
## $sessaoId - $chamadoCanonico

- Chamado: $chamadoCanonico
- Empresa: $empresa
- Usuario atual: $usuario
- Titulo: $($Titulo.Trim())
- Data/hora: $DataHora
- Status da sessao: feita
- Hash: $hash
- Resumo: $($Resumo.Trim())
"@
    Set-Content -LiteralPath $destino -Value $conteudo -Encoding UTF8
}

$resultado = [pscustomobject]@{
    Sessao     = $nnn
    Arquivo    = $destino
    Hash       = $hash
    Chamado    = $chamadoCanonico
    Pendente   = if ($pendente) { $pendente.FullName } else { $null }
}

if ($Json) { $resultado | ConvertTo-Json -Compress } else { $resultado }
