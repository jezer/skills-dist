param(
    [string]$KeyPath = "$env:USERPROFILE\.ssh\id_ed25519"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $KeyPath)) {
    throw "Chave privada nao encontrada: $KeyPath"
}

Set-Service ssh-agent -StartupType Automatic
Start-Service ssh-agent
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
ssh-add $KeyPath | Out-Null

[pscustomobject]@{
    ssh_agent = (Get-Service ssh-agent).Status
    key_loaded = $KeyPath
    ssh_command = (git config --global --get core.sshCommand)
}
