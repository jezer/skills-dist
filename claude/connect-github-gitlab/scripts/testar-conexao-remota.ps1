param(
    [ValidateSet("github", "gitlab", "ambos")]
    [string]$Host = "ambos"
)

$ErrorActionPreference = "Stop"

$targets = switch ($Host) {
    "github" { @("github.com") }
    "gitlab" { @("gitlab.com") }
    default { @("github.com", "gitlab.com") }
}

$result = @()
foreach ($t in $targets) {
    $out = ssh -T ("git@{0}" -f $t) 2>&1
    $exitCode = $LASTEXITCODE
    $joined = ($out -join " ")
    $ok = ($joined -match "successfully authenticated|Welcome to GitLab") -or ($exitCode -eq 0)
    $result += [pscustomobject]@{
        host = $t
        ok = $ok
        exit_code = $exitCode
        output = $joined
    }
}

$result
