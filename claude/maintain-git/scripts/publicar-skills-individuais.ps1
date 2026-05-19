param(
    [string]$SkillsRoot = "C:\codes\skills",
    [string]$GitHubOwner = "jezer",
    [string]$RepoPrefix = "skill",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Get-SkillDirs {
    param([string]$Root)
    Get-ChildItem -LiteralPath $Root -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md") }
}

function Ensure-Repo {
    param(
        [string]$SkillPath,
        [string]$Owner,
        [string]$Prefix,
        [switch]$Simulate
    )

    $skillName = Split-Path -Leaf $SkillPath
    $repoName = "$Prefix-$skillName"
    $fullRepo = "$Owner/$repoName"

    try {
        if (-not (Test-Path -LiteralPath (Join-Path $SkillPath ".git"))) {
            if (-not $Simulate) {
                git -C $SkillPath init | Out-Null
            }
        }

        if (-not $Simulate) {
            git -C $SkillPath checkout -B main | Out-Null
            git -C $SkillPath add -A
            $hasChanges = git -C $SkillPath status --porcelain
            if ($hasChanges) {
                git -C $SkillPath commit -m "chore(skill): bootstrap $skillName" | Out-Null
            }
        }

        $repoExists = $false
        try {
            gh repo view $fullRepo | Out-Null
            $repoExists = $true
        } catch {
            $repoExists = $false
        }

        if (-not $repoExists -and -not $Simulate) {
            gh repo create $fullRepo --public | Out-Null
        }

        if (-not $Simulate) {
            $hasOrigin = $false
            $remotes = git -C $SkillPath remote
            if ($remotes -and ($remotes -contains "origin")) {
                $hasOrigin = $true
            }

            if (-not $hasOrigin) {
                git -C $SkillPath remote add origin ("https://github.com/{0}/{1}.git" -f $Owner, $repoName)
            }

            git -C $SkillPath push -u origin main | Out-Null
        }

        [pscustomobject]@{
            Skill = $skillName
            Repo = $fullRepo
            Publicado = $true
            DryRun = [bool]$Simulate
            Erro = ""
        }
    } catch {
        [pscustomobject]@{
            Skill = $skillName
            Repo = $fullRepo
            Publicado = $false
            DryRun = [bool]$Simulate
            Erro = $_.Exception.Message
        }
    }
}

$result = @()
$dirs = Get-SkillDirs -Root $SkillsRoot

foreach ($dir in $dirs) {
    $result += Ensure-Repo -SkillPath $dir.FullName -Owner $GitHubOwner -Prefix $RepoPrefix -Simulate:$DryRun
}

$result
