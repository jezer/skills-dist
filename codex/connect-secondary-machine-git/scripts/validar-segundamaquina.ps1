param(
    [string]$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519",
    [ValidateSet("github", "gitlab", "ambos")]
    [string]$Host = "ambos"
)

$ErrorActionPreference = "Stop"

$fingerprint = ""
if (Test-Path -LiteralPath $KeyPath) {
    try { $fingerprint = (ssh-keygen -lf $KeyPath 2>$null | Select-Object -First 1) } catch {}
}

$targets = switch ($Host) {
    "github" { @("github.com") }
    "gitlab" { @("gitlab.com") }
    default { @("github.com", "gitlab.com") }
}

$tests = @()
foreach ($t in $targets) {
    $out = ssh -T ("git@{0}" -f $t) 2>&1
    $exitCode = $LASTEXITCODE
    $joined = ($out -join " ")
    $ok = ($joined -match "successfully authenticated|Welcome to GitLab") -or ($exitCode -eq 0)
    $tests += [pscustomobject]@{
        host = $t
        ok = $ok
        exit_code = $exitCode
        output = $joined
    }
}

[pscustomobject]@{
    key_path = $KeyPath
    fingerprint = $fingerprint
    connectivity = $tests
}
