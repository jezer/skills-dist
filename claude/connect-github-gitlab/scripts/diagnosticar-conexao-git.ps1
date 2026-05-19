param(
    [ValidateSet("github", "gitlab", "ambos")]
    [string]$Host = "ambos"
)

$ErrorActionPreference = "Stop"

function Test-HostConn {
    param([string]$Target)
    $out = ssh -T ("git@{0}" -f $Target) 2>&1
    $exitCode = $LASTEXITCODE
    $joined = ($out -join " ")
    $ok = ($joined -match "successfully authenticated|Welcome to GitLab") -or ($exitCode -eq 0)
    [pscustomobject]@{ host = $Target; ok = $ok; exit_code = $exitCode; detail = $joined }
}

$targets = switch ($Host) {
    "github" { @("github.com") }
    "gitlab" { @("gitlab.com") }
    default { @("github.com", "gitlab.com") }
}

$gitVersion = ""
try { $gitVersion = (git --version) } catch { $gitVersion = "git-nao-encontrado" }

$sshAgentStatus = ""
try { $sshAgentStatus = (Get-Service ssh-agent).Status } catch { $sshAgentStatus = "ssh-agent-indisponivel" }

$sshKeys = @()
try { $sshKeys = ssh-add -l 2>$null } catch {}

$conn = @()
foreach ($t in $targets) { $conn += Test-HostConn -Target $t }

[pscustomobject]@{
    git_version = $gitVersion
    ssh_agent_status = $sshAgentStatus
    ssh_keys = $sshKeys
    connectivity = $conn
}
