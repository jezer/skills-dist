param(
    [ValidateSet("github", "gitlab", "ambos")]
    [string]$Provider = "ambos"
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

$targets = switch ($Provider) {
    "github" { @("github.com") }
    "gitlab" { @("gitlab.com") }
    default { @("github.com", "gitlab.com") }
}

$result = @()
foreach ($t in $targets) {
    $out = cmd /c ("ssh -T git@{0} 2>&1" -f $t)
    $exitCode = $LASTEXITCODE
    $joined = ($out | Out-String).Trim()
    $ok = ($joined -match "successfully authenticated|Welcome to GitLab") -or ($exitCode -eq 0)
    $result += [pscustomobject]@{
        host = $t
        ok = $ok
        exit_code = $exitCode
        output = $joined
    }
}

$result
