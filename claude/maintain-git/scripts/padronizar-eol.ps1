param(
    [string]$Repositorio = ".",
    [switch]$Renormalizar
)

$ErrorActionPreference = "Stop"

$repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
$gitattributesPath = Join-Path $repoPath ".gitattributes"

$conteudo = @'
* text=auto
*.ps1 text eol=crlf
*.md text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
*.json text eol=lf
'@

Set-Content -LiteralPath $gitattributesPath -Value $conteudo -Encoding ascii
git -C $repoPath add .gitattributes

if ($Renormalizar) {
    git -C $repoPath add --renormalize .
}

[pscustomobject]@{
    Repositorio = $repoPath
    Gitattributes = $gitattributesPath
    Renormalizado = [bool]$Renormalizar
}
