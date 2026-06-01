param(
    [string]$IndexPath = "",
    [string]$WorkspaceRoot = "C:\codes",
    [string]$Mensagem = "ops(git): sync, commit e push em lote pelo indice",
    [switch]$Sync = $true,
    [switch]$Push = $true,
    [switch]$AllowMainMaster,
    [switch]$NoVerify,
    [switch]$DryRun,
    [switch]$ForceAddAll = $true,
    [switch]$RemoveProjectsWithoutRepoUrl,
    [switch]$UpdateMarkdownIndex,
    [switch]$RequireRepoUrlForSync
)

$ErrorActionPreference = "Stop"

function Resolve-IndexPath {
    param(
        [string]$ProvidedPath,
        [string]$Workspace
    )
    if ($ProvidedPath) { return (Resolve-Path -LiteralPath $ProvidedPath).Path }

    $machineTag = ""
    $customPath = Join-Path $Workspace "personalizado.md"
    if (Test-Path -LiteralPath $customPath) {
        $raw = Get-Content -LiteralPath $customPath -Raw
        if ($raw -match "Usuario atual:\s*([a-zA-Z0-9_-]+)") { $machineTag = $Matches[1].ToLowerInvariant() }
    }
    if (-not $machineTag) { $machineTag = $env:USERNAME.ToLowerInvariant() }

    $byMachine = Join-Path $Workspace ("indice-repositorios-root-{0}.json" -f $machineTag)
    if (Test-Path -LiteralPath $byMachine) { return $byMachine }
    return (Join-Path $Workspace "indice-repositorios-root.json")
}

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

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Get-ProjectPath {
    param([object]$Project)
    if ($Project.PSObject.Properties.Name -contains "full_path" -and -not [string]::IsNullOrWhiteSpace([string]$Project.full_path)) {
        return [string]$Project.full_path
    }
    return [string]$Project.path
}

function Get-RepoUrls {
    param([object]$Project)
    $urls = @()
    foreach ($remote in @($Project.remotes)) {
        if ($null -ne $remote -and $remote.PSObject.Properties.Name -contains "url") {
            $url = [string]$remote.url
            if (-not [string]::IsNullOrWhiteSpace($url)) { $urls += $url }
        }
    }
    foreach ($cloneUrl in @($Project.clone_urls)) {
        if ($cloneUrl -is [string] -and -not [string]::IsNullOrWhiteSpace($cloneUrl)) {
            $urls += [string]$cloneUrl
        }
    }
    return @($urls | Select-Object -Unique)
}

function Test-HasRepoUrl {
    param([object]$Project)
    return @((Get-RepoUrls -Project $Project)).Count -gt 0
}

function Add-FullPathProperty {
    param([object]$Project)
    $path = Get-ProjectPath -Project $Project
    if (-not ($Project.PSObject.Properties.Name -contains "full_path")) {
        $Project | Add-Member -NotePropertyName "full_path" -NotePropertyValue $path
    } elseif ([string]::IsNullOrWhiteSpace([string]$Project.full_path)) {
        $Project.full_path = $path
    }
}

function Update-IndexCounts {
    param([object]$Index)
    $allProjects = @()
    foreach ($company in @($Index.companies)) {
        $projects = @($company.projects)
        $company.projects_total = $projects.Count
        $company.git_repos_total = @($projects | Where-Object { $_.has_git }).Count
        $company.sem_git_total = @($projects | Where-Object { -not $_.has_git }).Count
        $allProjects += $projects
    }

    $Index.companies_total = @($Index.companies).Count
    $Index.projects_total = $allProjects.Count
    $Index.git_repos_total = @($allProjects | Where-Object { $_.has_git }).Count
    $Index.generated_at = (Get-Date).ToString("o")
}

function Remove-ProjectsWithoutUrl {
    param([object]$Index)
    $removed = @()

    foreach ($company in @($Index.companies)) {
        $kept = @()
        foreach ($project in @($company.projects)) {
            if (Test-HasRepoUrl -Project $project) {
                Add-FullPathProperty -Project $project
                $kept += $project
            } else {
                $removed += [pscustomobject]@{
                    Company = $company.name
                    Project = $project.project_name
                    RepoType = $project.repo_type
                    Path = Get-ProjectPath -Project $project
                }
            }
        }
        $company.projects = @($kept)
    }

    $gitRepos = @()
    if ($null -ne $Index.git_repos) {
        foreach ($repo in @($Index.git_repos)) {
            if (Test-HasRepoUrl -Project $repo) {
                Add-FullPathProperty -Project $repo
                $gitRepos += $repo
            }
        }
    } else {
        foreach ($company in @($Index.companies)) {
            foreach ($project in @($company.projects)) {
                if ($project.has_git -and $project.sync_enabled) { $gitRepos += $project }
            }
        }
    }
    $Index.git_repos = @($gitRepos | Where-Object { $_.has_git -and $_.sync_enabled })
    Update-IndexCounts -Index $Index
    return $removed
}

function Write-MarkdownIndex {
    param(
        [object]$Index,
        [string]$JsonPath,
        [object[]]$RemovedProjects
    )
    $mdPath = [System.IO.Path]::ChangeExtension($JsonPath, ".md")
    $lines = @()
    $lines += "# Indice de Repositorios Root"
    $lines += ""
    $lines += "- Workspace: $($Index.workspace_root)"
    $lines += "- Chamado: $($Index.ticket_id)"
    $lines += "- Gerado em: $($Index.generated_at)"
    $lines += "- Total de empresas: $($Index.companies_total)"
    $lines += "- Total de projetos: $($Index.projects_total)"
    $lines += "- Total de repositorios Git validos: $($Index.git_repos_total)"
    $lines += "- Entradas removidas por ausencia de URL de repositorio: $(@($RemovedProjects).Count)"
    $lines += ""
    $lines += "## Projetos por empresa"
    $lines += ""

    foreach ($company in @($Index.companies)) {
        $lines += "### $($company.name)"
        $lines += "- Raiz: $($company.root_path)"
        $lines += ""
        $lines += "| Projeto | Tipo | Git | Branch | URL | Status | Commit |"
        $lines += "|---------|------|-----|--------|-----|--------|--------|"
        foreach ($project in @($company.projects)) {
            $urls = @(Get-RepoUrls -Project $project)
            $url = if ($urls.Count -gt 0) { $urls[0] } else { "" }
            $git = if ($project.has_git) { "Sim" } else { "Nao" }
            $branch = if ($project.current_branch) { $project.current_branch } elseif ($project.default_branch) { $project.default_branch } else { "-" }
            $status = ([string]$project.status_short).Replace("|", "\|")
            $commit = if ($project.last_commit.hash) { $project.last_commit.hash } else { "-" }
            $lines += "| $($project.project_name) | $($project.repo_type) | $git | $branch | $url | $status | $commit |"
        }
        $lines += ""
    }

    if (@($RemovedProjects).Count -gt 0) {
        $lines += "## Entradas removidas por ausencia de URL de repositorio"
        $lines += ""
        $lines += "| Empresa | Projeto | Tipo | Caminho |"
        $lines += "|---------|---------|------|---------|"
        foreach ($removed in @($RemovedProjects | Sort-Object Company, Project)) {
            $lines += "| $($removed.Company) | $($removed.Project) | $($removed.RepoType) | $($removed.Path) |"
        }
        $lines += ""
    }

    Write-Utf8NoBom -Path $mdPath -Content ($lines -join "`r`n")
    return $mdPath
}

$IndexPath = Resolve-IndexPath -ProvidedPath $IndexPath -Workspace $WorkspaceRoot
if (-not (Test-Path -LiteralPath $IndexPath)) {
    throw "Indice nao encontrado: $IndexPath"
}

$idx = Get-Content -LiteralPath $IndexPath -Raw | ConvertFrom-Json
$removedProjects = @()
$markdownPath = [System.IO.Path]::ChangeExtension($IndexPath, ".md")

if ($RemoveProjectsWithoutRepoUrl) {
    $removedProjects = @(Remove-ProjectsWithoutUrl -Index $idx)
    if (-not $DryRun) {
        Write-Utf8NoBom -Path $IndexPath -Content ($idx | ConvertTo-Json -Depth 12)
        if ($UpdateMarkdownIndex) {
            $markdownPath = Write-MarkdownIndex -Index $idx -JsonPath $IndexPath -RemovedProjects $removedProjects
        }
    }
}

$repos = @()
if ($null -ne $idx.git_repos) {
    foreach ($repoEntry in @($idx.git_repos)) {
        if (-not $repoEntry.sync_enabled) { continue }
        if ($RequireRepoUrlForSync -and -not (Test-HasRepoUrl -Project $repoEntry)) { continue }
        $repos += (Get-ProjectPath -Project $repoEntry)
    }
} else {
    foreach ($company in @($idx.companies)) {
        foreach ($project in @($company.projects)) {
            if (-not ($project.has_git -and $project.sync_enabled)) { continue }
            if ($RequireRepoUrlForSync -and -not (Test-HasRepoUrl -Project $project)) { continue }
            $repos += (Get-ProjectPath -Project $project)
        }
    }
}
$repos = @(
    $repos |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    Sort-Object -Unique |
    Sort-Object @{ Expression = { $_.Length }; Descending = $true }, @{ Expression = { $_ }; Ascending = $true }
)

$resultados = @()
foreach ($repo in $repos) {
    if (-not (Test-Path -LiteralPath (Join-Path $repo ".git"))) {
        $resultados += [pscustomobject]@{ Repo = $repo; Branch = ""; Resultado = "ignorado_sem_git_local"; Commit = "" }
        continue
    }

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
            try {
                Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "pull", "--rebase", "origin", $branch) | Out-Null
            } catch {
                Write-Warning "Falha no pull inicial em $repo. Tentando commit primeiro."
            }
        }

        $status = Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "status", "--porcelain")
        if (-not $status) {
            if ($Push -and $hasOrigin -and -not $DryRun) {
                Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "push", "-u", "origin", $branch) | Out-Null
                $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "sincronizado_sem_alteracoes_novas"; Commit = "" }
            } else {
                $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "sem_alteracoes"; Commit = "" }
            }
            continue
        }

        if ($DryRun) {
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "dry_run_pronto"; Commit = "" }
            continue
        }

        if ($ForceAddAll) {
            Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "add", "-A")
        }

        $commitArgs = @("-C", $repo, "commit", "-m", $Mensagem)
        if ($NoVerify) { $commitArgs += "--no-verify" }
        Invoke-GitSafe -RepoPath $repo -GitArgs $commitArgs | Out-Null
        $hash = (Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "rev-parse", "--short", "HEAD") | Out-String).Trim()

        if ($Sync -and $hasOrigin) {
            Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "pull", "--rebase", "origin", $branch) | Out-Null
        }

        if ($Push -and $hasOrigin) {
            Invoke-GitSafe -RepoPath $repo -GitArgs @("-C", $repo, "push", "-u", "origin", $branch) | Out-Null
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "sync_commit_push_completo"; Commit = $hash }
        } else {
            $resultados += [pscustomobject]@{ Repo = $repo; Branch = $branch; Resultado = "commitado_local"; Commit = $hash }
        }
    } catch {
        $resultados += [pscustomobject]@{ Repo = $repo; Branch = ""; Resultado = "falha: $($_.Exception.Message)"; Commit = "" }
    }
}

[pscustomobject]@{
    IndexPath = $IndexPath
    MarkdownPath = $markdownPath
    DryRun = [bool]$DryRun
    RemovedProjectsWithoutRepoUrl = @($removedProjects).Count
    RepositoriesSelected = @($repos).Count
    Results = $resultados
}
