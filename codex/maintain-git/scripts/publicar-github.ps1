param(
    [Parameter(Mandatory = $true)][string]$Repositorio,
    [string]$Nome,
    [ValidateSet("private", "public")][string]$Visibilidade = "private"
)

$ErrorActionPreference = "Stop"

$repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
if (-not $Nome) {
    $Nome = Split-Path -Leaf $repoPath
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "gh nao encontrado no PATH."
}

& gh auth status | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "gh sem autenticacao valida. Execute 'gh auth login -h github.com' e tente novamente."
}

$repoName = ($Nome.ToLowerInvariant() -replace '[^a-z0-9-]', '-').Trim('-')
if (-not $repoName) {
    throw "Nome normalizado do repositorio GitHub vazio."
}

$repoExiste = $false
try {
    & gh repo view $repoName --json name --jq .name | Out-Null
    if ($LASTEXITCODE -eq 0) { $repoExiste = $true }
} catch {
    $repoExiste = $false
}

if ($repoExiste) {
    $url = (& gh repo view $repoName --json url --jq .url).Trim()
    $temOrigin = $false
    try {
        & git -C $repoPath remote get-url origin *> $null
        if ($LASTEXITCODE -eq 0) { $temOrigin = $true }
    } catch {
        $temOrigin = $false
    }

    if (-not $temOrigin) {
        git -C $repoPath remote add origin $url
    }
} else {
    gh repo create $repoName --$Visibilidade --source $repoPath --remote origin | Out-Null
}

[pscustomobject]@{
    Repositorio = $repoPath
    Nome = $repoName
    Visibilidade = $Visibilidade
}
