param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot,
    [string]$MachineTag = ""
)

$ErrorActionPreference = "Stop"

if (-not $MachineTag) {
    $customPath = Join-Path $WorkspaceRoot "personalizado.md"
    if (Test-Path -LiteralPath $customPath) {
        $raw = Get-Content -LiteralPath $customPath -Raw
        if ($raw -match "Usuario atual:\s*([a-zA-Z0-9_-]+)") { $MachineTag = $Matches[1].ToLowerInvariant() }
    }
    if (-not $MachineTag) { $MachineTag = $env:USERNAME.ToLowerInvariant() }
}

$jsonPath = Join-Path $WorkspaceRoot ("indice-repositorios-root-{0}.json" -f $MachineTag)
if (-not (Test-Path -LiteralPath $jsonPath)) {
    $jsonPath = Join-Path $WorkspaceRoot "indice-repositorios-root.json"
}
if (-not (Test-Path -LiteralPath $jsonPath)) {
    throw "Indice nao encontrado: $jsonPath"
}

$idx = Get-Content -Raw -LiteralPath $jsonPath | ConvertFrom-Json
$naoSync = @()
foreach ($c in $idx.companies) {
    foreach ($p in $c.projects) {
        if (-not $p.sync_enabled) {
            $naoSync += "$($c.name)/$($p.project_name)"
        }
    }
}

[pscustomobject]@{
    workspace = $WorkspaceRoot
    machine_tag = $MachineTag
    gerado_em = $idx.generated_at
    chamado = $idx.ticket_id
    empresas = $idx.companies_total
    projetos = $idx.projects_total
    repos_git = $idx.git_repos_total
    itens_nao_sincronizaveis = $naoSync.Count
}
