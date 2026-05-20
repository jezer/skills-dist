param(
    [string]$Repositorio = ".",
    [string]$Mensagem,
    [switch]$AddAll,
    [switch]$Push = $true,
    [switch]$Sync = $true,
    [switch]$NoVerify,
    [switch]$AllowMainMaster,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Invoke-GitSafe {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )
    & git "-c" "safe.directory=$RepoPath" @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw ("Falha ao executar git " + ($GitArgs -join " "))
    }
}

$repoPath = (Resolve-Path -LiteralPath $Repositorio).Path
$branch = (Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "branch", "--show-current")).Trim()

if ((-not $AllowMainMaster) -and (@("main", "master") -contains $branch)) {
    throw "Commit/push bloqueado na branch '$branch'. Crie uma branch de trabalho antes."
}

if ($Sync -and -not $DryRun) {
    Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "pull", "--rebase")
}

if ($AddAll) {
    Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "add", "-A")
}

$status = Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "status", "--porcelain")
if (-not $status) {
    throw "Nenhuma alteracao detectada para commit em $repoPath."
}

if (-not $Mensagem) {
    $Mensagem = Read-Host "Mensagem de commit (formato tipo(escopo): resumo)"
}

$mensagemNorm = $Mensagem.Trim()
if (-not $mensagemNorm) {
    throw "Mensagem de commit vazia."
}

if ($DryRun) {
    [pscustomobject]@{
        Repositorio = $repoPath
        Branch = $branch
        Mensagem = $mensagemNorm
        Staged = [bool]$status
        Commit = $false
        CommitHash = $null
        Push = $false
        DryRun = $true
    }
    return
}

$commitArgs = @("-C", $repoPath, "commit", "-m", $mensagemNorm)
if ($NoVerify) {
    $commitArgs += "--no-verify"
}
Invoke-GitSafe -RepoPath $repoPath -GitArgs $commitArgs | Out-Null

$commitHash = (Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "rev-parse", "--short", "HEAD")).Trim()

if ($Push) {
    Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "push", "-u", "origin", "HEAD")
}

$syncStatus = "nao_validado"
if (($Push -or $Sync) -and -not $DryRun) {
    try {
        Invoke-GitSafe -RepoPath $repoPath -GitArgs @("-C", $repoPath, "fetch", "origin") | Out-Null
        $syncStatus = "ok"
    } catch {
        $syncStatus = "falha_validacao_sync"
    }
}

[pscustomobject]@{
    Repositorio = $repoPath
    Branch = $branch
    Mensagem = $mensagemNorm
    Commit = $true
    CommitHash = $commitHash
    Push = [bool]$Push
    Sync = [bool]$Sync
    SyncValidation = $syncStatus
    DryRun = $false
}
