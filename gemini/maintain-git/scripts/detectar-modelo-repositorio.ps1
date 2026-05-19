param(
    [string]$Repositorio = "."
)

$ErrorActionPreference = "Stop"

$repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
$conv = Join-Path $repoPath "git-convencoes.md"
$modelo = "indefinido"

if (Test-Path -LiteralPath $conv) {
    $lines = Get-Content -LiteralPath $conv
    foreach ($l in $lines) {
        if ($l -match '^\s*-\s*ModeloRepositorio:\s*(.+?)\s*$') {
            $m = $matches[1].Trim().ToLowerInvariant()
            if ($m -in @("multi-repositorio", "mono-repositorio")) {
                $modelo = $m
            }
            break
        }
    }
}

[pscustomobject]@{
    Repositorio = $repoPath
    Convencoes = $conv
    ModeloRepositorio = $modelo
}
