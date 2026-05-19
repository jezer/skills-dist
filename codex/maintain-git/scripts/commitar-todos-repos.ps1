param(
    [string]$IndexPath = "C:\codes\indice-repositorios-root.json",
    [string]$Mensagem = "ops(git): sync, commit e push em lote pelo indice",
    [switch]$Sync = $true,
    [switch]$Push = $true,
    [switch]$AllowMainMaster,
    [switch]$NoVerify,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Invoke-GitSafe {
    param(
        [Parameter(Mandatory = $true)][string]$RepoPath,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )
    & git "-c" "safe.directory=$RepoPath" @GitArgs
}

if (-not (Test-Path -LiteralPath $IndexPath)) {
    throw "Indice nao encontrado: $IndexPath"
}

$idx = Get-Content -LiteralPath $IndexPath -Raw | ConvertFrom-Json
$repos = @()
foreach ($c in $idx.companies) {
    foreach ($p in $c.projects) {
        if ($p.has_git -and $p.sync_enabled) {
            $repos += $p.path
        }
    }
}
$repos = $repos | Sort-Object -Unique

$resultados = @()
foreach ($repo in $repos) {
    if (-not (Test-Path -LiteralPath (Join-Path $repo ".git"))) { continue }

    try {
        $branch = (Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "branch", "--show-current") | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($branch)) {
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = ""; Resultado = "falha_branch"; Commit = "" }
            continue
        }

        if ((-not $AllowMainMaster) -and ($branch -in @("main", "master"))) {
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "ignorado_branch_protegida"; Commit = "" }
            continue
        }

        $hasOrigin = $false
        $remotes = (Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "remote") | Out-String).Trim()
        if ($remotes -match "(?m)^origin$") { $hasOrigin = $true }

        if ($Sync -and $hasOrigin -and -not $DryRun) {
            Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "pull", "--rebase", "origin", $branch) | Out-Null
        }

        $status = Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "status", "--porcelain")
        if (-not $status) {
            if ($Push -and $hasOrigin -and -not $DryRun) {
                Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "push", "-u", "origin", $branch) | Out-Null
                $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "sincronizado_sem_alteracoes"; Commit = "" }
            } else {
                $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "sem_alteracoes"; Commit = "" }
            }
            continue
        }

        if ($DryRun) {
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "dry_run_pronto"; Commit = "" }
            continue
        }

        Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "add", "-A")
        $commitArgs = @("-C", $repo, "commit", "-m", $Mensagem)
        if ($NoVerify) { $commitArgs += "--no-verify" }
        Invoke-GitSafe -RepoPath $repo -GitArgs $commitArgs | Out-Null
        $hash = (Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "rev-parse", "--short", "HEAD") | Out-String).Trim()

        if ($Push -and $hasOrigin) {
            Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "push", "-u", "origin", $branch) | Out-Null
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "sync_commit_push"; Commit = $hash }
        } else {
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "commitado_sem_push"; Commit = $hash }
        }
    } catch {
        $resultados += [pscustomobject]@{ Repo = $repo; Branch = ""; Resultado = "falha: $($_.Exception.Message)"; Commit = "" }
    }
}

$resultados
