param(
    [string]$WorkspaceRoot = "C:\codes",
    [string]$TicketId = "",
    [string[]]$Empresas = @("pv", "syg", "cnu", "theo", "elohim", "skills", "tools"),
    [switch]$JsonOnly
)

$ErrorActionPreference = "Stop"

function Get-RepoInfo {
    param(
        [string]$Empresa,
        [string]$Path
    )

    $nome = if ($Empresa -eq "root") { "codes-root" } else { Split-Path -Leaf $Path }
    $hasGit = Test-Path (Join-Path $Path ".git")
    $repoType = if ($hasGit) {
        "repo"
    } elseif ($nome -in @("plan", "indices", "referencia", "gemini")) {
        "suporte"
    } else {
        "sem-git"
    }

    $syncEnabled = $hasGit
    $syncReason = if ($syncEnabled) { "" } else { "sem repositorio git local" }

    $branch = ""
    $tracking = ""
    $status = ""
    $lastHash = ""
    $lastDate = ""
    $lastSubject = ""
    $remotes = @()
    $cloneUrls = @()

    if ($hasGit) {
        try { $branch = (git -c safe.directory=$Path -C $Path rev-parse --abbrev-ref HEAD 2>$null).Trim() } catch {}
        try { $tracking = (git -c safe.directory=$Path -C $Path rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null).Trim() } catch {}
        try { $status = (git -c safe.directory=$Path -C $Path status --short --branch 2>$null | Select-Object -First 1).Trim() } catch {}
        try {
            $log = (git -c safe.directory=$Path -C $Path log -1 --pretty=format:'%h|%cI|%s' 2>$null).Trim()
            if ($log) {
                $parts = $log -split '\|', 3
                $lastHash = $parts[0]
                $lastDate = $parts[1]
                $lastSubject = $parts[2]
            }
        } catch {}
        try {
            $rms = git -c safe.directory=$Path -C $Path remote -v 2>$null
            foreach ($line in $rms) {
                if ($line -match '^(\S+)\s+(\S+)\s+\((fetch|push)\)$') {
                    $name = $Matches[1]
                    $url = $Matches[2]
                    if (-not ($remotes | Where-Object { $_.name -eq $name -and $_.url -eq $url })) {
                        $remotes += [pscustomobject]@{ name = $name; url = $url }
                        $cloneUrls += $url
                    }
                }
            }
        } catch {}
    }

    $remoteCount = @($remotes).Count
    $riskLevel = if ($hasGit) {
        if ($remoteCount -eq 0) { "atencao" } else { "ok" }
    } else {
        if ($repoType -eq "suporte") { "ok" } else { "atencao" }
    }

    $notes = if ($hasGit) {
        if ($remoteCount -eq 0) { "repositorio sem remote configurado" } else { "repositorio valido" }
    } else {
        if ($repoType -eq "suporte") { "diretorio de suporte sem git proprio (esperado)" } else { "projeto sem repositorio git (regularizar quando aplicavel)" }
    }

    [pscustomobject]@{
        company = $Empresa
        project_name = $nome
        path = $Path
        repo_type = $repoType
        has_git = $hasGit
        default_branch = $branch
        tracking_branch = $tracking
        remotes = $remotes
        clone_urls = ($cloneUrls | Select-Object -Unique)
        last_commit = [pscustomobject]@{
            hash = $lastHash
            date = $lastDate
            subject = $lastSubject
        }
        status_short = $status
        risk_level = $riskLevel
        notes = $notes
        sync_enabled = $syncEnabled
        sync_block_reason = $syncReason
    }
}

$allProjects = @()
foreach ($emp in $Empresas) {
    $root = Join-Path $WorkspaceRoot $emp
    if (-not (Test-Path $root)) { continue }
    $dirs = Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue
    foreach ($d in $dirs) {
        $allProjects += Get-RepoInfo -Empresa $emp -Path $d.FullName
    }
}

# Inclui explicitamente o repositorio raiz do workspace no indice.
$allProjects += Get-RepoInfo -Empresa "root" -Path $WorkspaceRoot

$companies = @()
foreach ($emp in $Empresas) {
    $items = @($allProjects | Where-Object { $_.company -eq $emp })
    $companies += [pscustomobject]@{
        name = $emp
        root_path = (Join-Path $WorkspaceRoot $emp)
        projects = $items
        projects_total = $items.Count
        git_repos_total = @($items | Where-Object { $_.has_git }).Count
        sem_git_total = @($items | Where-Object { -not $_.has_git }).Count
    }
}

$rootItems = @($allProjects | Where-Object { $_.company -eq "root" })
$companies += [pscustomobject]@{
    name = "root"
    root_path = $WorkspaceRoot
    projects = $rootItems
    projects_total = $rootItems.Count
    git_repos_total = @($rootItems | Where-Object { $_.has_git }).Count
    sem_git_total = @($rootItems | Where-Object { -not $_.has_git }).Count
}

$jsonObj = [pscustomobject]@{
    generated_at = (Get-Date).ToString("o")
    workspace_root = $WorkspaceRoot
    ticket_id = $TicketId
    companies_total = $companies.Count
    projects_total = $allProjects.Count
    git_repos_total = @($allProjects | Where-Object { $_.has_git }).Count
    companies = $companies
}

$jsonPath = Join-Path $WorkspaceRoot "indice-repositorios-root.json"
$jsonObj | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

if (-not $JsonOnly) {
    $mdPath = Join-Path $WorkspaceRoot "indice-repositorios-root.md"
    $naoSync = @()
    foreach ($c in $companies) {
        foreach ($p in $c.projects) {
            if (-not $p.sync_enabled) {
                $naoSync += "$($c.name)/$($p.project_name) - $($p.sync_block_reason)"
            }
        }
    }

    $lines = @()
    $lines += "# Indice de Repositorios Root"
    $lines += ""
    $lines += "- Workspace: $WorkspaceRoot"
    $lines += "- Chamado: $TicketId"
    $lines += "- Gerado em: $($jsonObj.generated_at)"
    $lines += "- Total de empresas: $($jsonObj.companies_total)"
    $lines += "- Total de projetos: $($jsonObj.projects_total)"
    $lines += "- Total de repositorios Git validos: $($jsonObj.git_repos_total)"
    $lines += "- Itens nao sincronizaveis: $($naoSync.Count)"
    $lines += ""
    $lines += "## Resumo por empresa"
    $lines += ""
    foreach ($c in $companies) {
        $lines += "### $($c.name)"
        $lines += "- Raiz: $($c.root_path)"
        $lines += "- Projetos encontrados: $($c.projects_total)"
        $lines += "- Repos Git validos: $($c.git_repos_total)"
        $lines += "- Projetos sem Git: $($c.sem_git_total)"
        $lines += ""
    }
    Set-Content -LiteralPath $mdPath -Value ($lines -join "`r`n") -Encoding UTF8
}

[pscustomobject]@{
    JsonPath = $jsonPath
    MarkdownPath = (Join-Path $WorkspaceRoot "indice-repositorios-root.md")
    Companies = $jsonObj.companies_total
    Projects = $jsonObj.projects_total
    GitRepos = $jsonObj.git_repos_total
}
