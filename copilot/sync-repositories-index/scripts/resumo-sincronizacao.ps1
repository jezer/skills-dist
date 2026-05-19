param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot
)

$ErrorActionPreference = "Stop"

$jsonPath = Join-Path $WorkspaceRoot "indice-repositorios-root.json"
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
    gerado_em = $idx.generated_at
    chamado = $idx.ticket_id
    empresas = $idx.companies_total
    projetos = $idx.projects_total
    repos_git = $idx.git_repos_total
    itens_nao_sincronizaveis = $naoSync.Count
}
