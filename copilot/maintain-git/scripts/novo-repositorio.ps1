param(
    [ValidateSet("pv", "syg", "cnu", "theo", "elohim", "skills", "tools")][string]$Empresa,
    [string]$Nome,
    [string]$CaminhoRepositorio,
    [string]$BasePath = "C:\codes",
    [switch]$Init,
    [switch]$CriarGitHub,
    [ValidateSet("private", "public")][string]$Visibilidade = "private"
)

$ErrorActionPreference = "Stop"

function Invoke-GitSafe {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )
    & git "-c" "safe.directory=$RepoPath" @GitArgs
}

function Resolve-RespostaSim {
    param([string]$Valor)
    if ($null -eq $Valor) { return $false }
    return ($Valor.Trim().ToLowerInvariant() -match '^(s|sim|y|yes)$')
}

function Get-ConvencoesInfo {
    param([string]$Repositorio)

    $convencoesPath = Join-Path $Repositorio "git-convencoes.md"
    if (-not (Test-Path -LiteralPath $convencoesPath)) {
        return $null
    }

    $conteudo = Get-Content -LiteralPath $convencoesPath -ErrorAction SilentlyContinue
    $repoNome = $null
    $basePathConv = $null
    $modeloConv = $null

    foreach ($linha in $conteudo) {
        if (-not $repoNome -and $linha -match '^\s*-?\s*Repositorio:\s*(.+?)\s*$') {
            $repoNome = $matches[1].Trim()
        }
        if (-not $basePathConv -and $linha -match '^\s*-?\s*BasePath:\s*(.+?)\s*$') {
            $basePathConv = $matches[1].Trim()
        }
        if (-not $modeloConv -and $linha -match '^\s*-?\s*ModeloRepositorio:\s*(.+?)\s*$') {
            $modeloConv = $matches[1].Trim().ToLowerInvariant()
        }
    }

    [pscustomobject]@{
        Repositorio = $repoNome
        BasePath = $basePathConv
        ModeloRepositorio = $modeloConv
        Caminho = $convencoesPath
    }
}

if (-not $Empresa) {
    if ($CaminhoRepositorio) {
        $Empresa = Split-Path -Leaf (Split-Path -Path $CaminhoRepositorio -Parent)
    } else {
        $Empresa = (Read-Host "Empresa (pv, syg, cnu, theo, elohim, skills, tools)").Trim().ToLowerInvariant()
    }
}

if (-not @("pv", "syg", "cnu", "theo", "elohim", "skills", "tools").Contains($Empresa)) {
    throw "Empresa invalida: $Empresa"
}

if (-not $Nome) {
    if ($CaminhoRepositorio) {
        $convencoesInfo = Get-ConvencoesInfo -Repositorio $CaminhoRepositorio
        if ($convencoesInfo -and $convencoesInfo.Repositorio) {
            $Nome = $convencoesInfo.Repositorio
        } else {
            $Nome = Split-Path -Leaf $CaminhoRepositorio
        }
    } else {
        $Nome = Read-Host "Nome do repositorio"
    }
}

$nomeNorm = ($Nome.ToLowerInvariant() -replace '[^a-z0-9-]', '-').Trim('-')
if (-not $nomeNorm) {
    throw "Nome normalizado vazio."
}

$empresaNorm = $Empresa.ToLowerInvariant()
if ($CaminhoRepositorio) {
    $repoPath = $CaminhoRepositorio
} else {
    $empresaPath = Join-Path $BasePath $Empresa
    $repoPath = Join-Path $empresaPath $nomeNorm
}

if ($CaminhoRepositorio) {
    $convencoesInfo = Get-ConvencoesInfo -Repositorio $repoPath
    if ($convencoesInfo) {
        if (-not $PSBoundParameters.ContainsKey("Nome") -and $convencoesInfo.Repositorio) {
            $Nome = $convencoesInfo.Repositorio
            $nomeNorm = ($Nome.ToLowerInvariant() -replace '[^a-z0-9-]', '-').Trim('-')
        }
        if ($convencoesInfo.BasePath) {
            $BasePath = $convencoesInfo.BasePath
        }
        if ($convencoesInfo.ModeloRepositorio -and $convencoesInfo.ModeloRepositorio -notin @("multi-repositorio", "mono-repositorio")) {
            throw "ModeloRepositorio invalido em git-convencoes.md: $($convencoesInfo.ModeloRepositorio)"
        }
    }
}

if (-not (Test-Path -LiteralPath $repoPath)) {
    New-Item -ItemType Directory -Path $repoPath -Force | Out-Null
}

if (-not $PSBoundParameters.ContainsKey("Init")) {
    $Init = Resolve-RespostaSim (Read-Host "Inicializar repositorio Git agora? [s/N]")
}

$gitJaInicializado = Test-Path -LiteralPath (Join-Path $repoPath ".git")
if ($Init) {
    if ($gitJaInicializado) {
        $Init = $false
        Write-Host "Repositorio Git ja inicializado: $repoPath. Seguindo sem reinicializar."
    } else {
        Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "init") | Out-Null
    }
}

$convencoesPath = Join-Path $repoPath "git-convencoes.md"
if (-not (Test-Path -LiteralPath $convencoesPath)) {
    $basePathConvencoes = if ($CaminhoRepositorio) { $repoPath } else { $BasePath }
    $modelo = "mono-repositorio"
    if ($repoPath -in @("C:\\codes","C:\\codes\\skills","C:\\codes\\tools","C:\\codes\\pv","C:\\codes\\syg","C:\\codes\\cnu","C:\\codes\\theo","C:\\codes\\elohim")) {
        $modelo = "multi-repositorio"
    }
    & (Join-Path $PSScriptRoot "gravar-convencoes.ps1") -Repositorio $repoPath -Empresa $empresaNorm -Nome $nomeNorm -BasePath $basePathConvencoes -ModeloRepositorio $modelo | Out-Null
}

if (-not $PSBoundParameters.ContainsKey("CriarGitHub")) {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        $CriarGitHub = Resolve-RespostaSim (Read-Host "Criar repositorio no GitHub agora? [s/N]")
    } else {
        $CriarGitHub = $false
    }
}

if ($CriarGitHub) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        throw "gh nao encontrado no PATH."
    }
    & gh auth status | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "gh sem autenticacao valida. Execute 'gh auth login -h github.com' e tente novamente."
    }

    $repoGitHub = $nomeNorm
    if (-not $repoGitHub) {
        throw "Nome do repositorio GitHub nao definido."
    }

    $ghView = & gh repo view $repoGitHub 2>$null
    if ($LASTEXITCODE -eq 0) {
        $url = & gh repo view $repoGitHub --json url --jq .url
        if (-not (Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "remote", "get-url", "origin") 2>$null)) {
            Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "remote", "add", "origin", $url) | Out-Null
        }
    } else {
        & gh repo create $repoGitHub --$Visibilidade --source $repoPath --remote origin | Out-Null
    }
}

[pscustomobject]@{
    Repositorio = $repoPath
    Empresa = $empresaNorm
    Nome = $nomeNorm
    Inicializado = [bool]$Init
    Existente = [bool](Test-Path -LiteralPath $repoPath)
    Convencoes = $convencoesPath
    GitHub = [bool]$CriarGitHub
    Visibilidade = $Visibilidade
}
