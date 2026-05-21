param(
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceRoot,
    [ValidateSet("", "jf", "jz")]
    [string]$UsuarioMaquina = ""
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
    usuario_maquina = $UsuarioMaquina
    indice_json = $jsonPath
    gerado_em = $idx.generated_at
    chamado = $idx.ticket_id
    empresas = $idx.companies_total
    projetos = $idx.projects_total
    repos_git = $idx.git_repos_total
    itens_nao_sincronizaveis = $naoSync.Count
}
