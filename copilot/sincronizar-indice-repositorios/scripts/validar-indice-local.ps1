param(
    [string]$WorkspaceRoot = "C:\codes",
    [ValidateSet("", "jf", "jz")]
    [string]$UsuarioMaquina = "",
    [string[]]$Empresas = @("pv", "syg", "cnu", "theo", "elohim", "skills", "tools")
)

$ErrorActionPreference = "Stop"

function Resolve-UsuarioMaquina {
    param(
        [string]$WorkspaceRoot,
        [string]$UsuarioInformado
    )

    if (-not [string]::IsNullOrWhiteSpace($UsuarioInformado)) {
        return $UsuarioInformado.ToLowerInvariant()
    }

    $personalizadoPath = Join-Path $WorkspaceRoot "personalizado.md"
    if (-not (Test-Path -LiteralPath $personalizadoPath)) {
        throw "Nao foi possivel identificar o usuario da maquina: personalizado.md nao encontrado em $personalizadoPath"
    }

    $personalizado = Get-Content -Raw -LiteralPath $personalizadoPath
    if ($personalizado -match '(?im)^\s*-\s*Usuario atual:\s*(jf|jz)\s*$') {
        return $Matches[1].ToLowerInvariant()
    }

    throw "Nao foi possivel identificar o usuario da maquina em $personalizadoPath. Use 'Usuario atual: jf' ou 'Usuario atual: jz'."
}

$UsuarioMaquina = Resolve-UsuarioMaquina -WorkspaceRoot $WorkspaceRoot -UsuarioInformado $UsuarioMaquina
$jsonPath = Join-Path $WorkspaceRoot "indice-repositorios-root-$UsuarioMaquina.json"
if (-not (Test-Path -LiteralPath $jsonPath)) {
    throw "Indice nao encontrado: $jsonPath"
}

$idx = Get-Content -Raw -LiteralPath $jsonPath | ConvertFrom-Json
$indexMap = @{}
foreach ($c in $idx.companies) {
    foreach ($p in $c.projects) {
        $indexMap[$p.path.ToLowerInvariant()] = $true
    }
}

$detected = @()
foreach ($emp in $Empresas) {
    $root = Join-Path $WorkspaceRoot $emp
    if (-not (Test-Path $root)) { continue }
    $dirs = Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue
    foreach ($d in $dirs) {
        $detected += $d.FullName
    }
}

$faltandoNoIndice = @()
foreach ($p in $detected) {
    if (-not $indexMap.ContainsKey($p.ToLowerInvariant())) {
        $faltandoNoIndice += $p
    }
}

$inexistentesNoDisco = @()
foreach ($c in $idx.companies) {
    foreach ($p in $c.projects) {
        if (-not (Test-Path -LiteralPath $p.path)) {
            $inexistentesNoDisco += $p.path
        }
    }
}

$itensNaoSync = @()
foreach ($c in $idx.companies) {
    foreach ($p in $c.projects) {
        if (-not $p.sync_enabled) {
            $itensNaoSync += "$($c.name)/$($p.project_name): $($p.sync_block_reason)"
        }
    }
}

$pendencias = @()
if ($faltandoNoIndice.Count -gt 0) { $pendencias += "projetos_novos_nao_indexados=$($faltandoNoIndice.Count)" }
if ($inexistentesNoDisco.Count -gt 0) { $pendencias += "projetos_no_indice_sem_pasta=$($inexistentesNoDisco.Count)" }

[pscustomobject]@{
    usuario_maquina = $UsuarioMaquina
    indice_json = $jsonPath
    indice_atualizado = ($pendencias.Count -eq 0)
    pendencias_detectadas = $pendencias
    projetos_novos_nao_indexados = $faltandoNoIndice
    projetos_no_indice_sem_pasta = $inexistentesNoDisco
    itens_nao_sincronizaveis = $itensNaoSync
}
