param(
    [string]$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519",
    [switch]$SkipAddKey
)

$ErrorActionPreference = "Stop"

Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent

git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

if (-not $SkipAddKey) {
    if (-not (Test-Path -LiteralPath $KeyPath)) {
        throw "Chave privada nao encontrada: $KeyPath"
    }
    ssh-add $KeyPath | Out-Null
}

[pscustomobject]@{
    ssh_agent = (Get-Service ssh-agent).Status
    core_ssh_command = (git config --global --get core.sshCommand)
    key_added = (-not $SkipAddKey)
    key_path = $KeyPath
}
