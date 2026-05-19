param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePrivateKey,
    [Parameter(Mandatory = $true)]
    [string]$SourcePublicKey,
    [string]$TargetDir = "$env:USERPROFILE\.ssh",
    [string]$TargetKeyName = "id_ed25519"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $SourcePrivateKey)) { throw "Private key nao encontrada: $SourcePrivateKey" }
if (-not (Test-Path -LiteralPath $SourcePublicKey)) { throw "Public key nao encontrada: $SourcePublicKey" }

New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

$targetPrivate = Join-Path $TargetDir $TargetKeyName
$targetPublic = "$targetPrivate.pub"

Copy-Item -LiteralPath $SourcePrivateKey -Destination $targetPrivate -Force
Copy-Item -LiteralPath $SourcePublicKey -Destination $targetPublic -Force

[pscustomobject]@{
    private_key = $targetPrivate
    public_key = $targetPublic
}
