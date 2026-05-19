param(
    [Parameter(Mandatory = $true)]
    [string]$Email,
    [string]$KeyName = "id_ed25519",
    [string]$TargetDir = "$env:USERPROFILE\.ssh"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
$keyPath = Join-Path $TargetDir $KeyName

if (Test-Path -LiteralPath $keyPath) {
    throw "Chave ja existe: $keyPath"
}

ssh-keygen -t ed25519 -C $Email -f $keyPath -N "" | Out-Null

[pscustomobject]@{
    private_key = $keyPath
    public_key = "$keyPath.pub"
}
