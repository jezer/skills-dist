param(
    [string]$WorkspaceRoot = "C:\codes",
    [string[]]$Empresas = @("pv", "syg", "cnu", "theo", "elohim", "skills", "tools")
)

$ErrorActionPreference = "Stop"

$jsonPath = Join-Path $WorkspaceRoot "indice-repositorios-root.json"
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
    indice_atualizado = ($pendencias.Count -eq 0)
    pendencias_detectadas = $pendencias
    projetos_novos_nao_indexados = $faltandoNoIndice
    projetos_no_indice_sem_pasta = $inexistentesNoDisco
    itens_nao_sincronizaveis = $itensNaoSync
}
