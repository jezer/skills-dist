#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Configura acesso remoto ao PostgreSQL na rede local (LAN/Wi-Fi).
.DESCRIPTION
    1. Verifica e corrige o perfil de rede das interfaces (Public → Private quando necessario).
    2. Adiciona entrada para a subnet no pg_hba.conf se ausente.
    3. Cria ou atualiza regra de firewall TCP para a porta PostgreSQL.
    4. Recarrega a configuracao do PostgreSQL.
.PARAMETER PostgreSQLVersion
    Versao do PostgreSQL (padrao: 18).
.PARAMETER Subnet
    Subnet CIDR permitida (padrao: 192.168.1.0/24).
.PARAMETER Port
    Porta PostgreSQL (padrao: 5432).
.PARAMETER AuthMethod
    Metodo de autenticacao no pg_hba.conf (padrao: scram-sha-256).
.PARAMETER SetNetworkPrivate
    Se verdadeiro, altera interfaces com IP na subnet para perfil Private (padrao: $true).
.EXAMPLE
    .\configure-remote-access.ps1
    .\configure-remote-access.ps1 -Subnet "10.0.0.0/24" -Port 5432
#>
param(
    [string]$PostgreSQLVersion  = "18",
    [string]$Subnet             = "192.168.1.0/24",
    [int]   $Port               = 5432,
    [string]$AuthMethod         = "scram-sha-256",
    [bool]  $SetNetworkPrivate  = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$dataDir      = "C:\Program Files\PostgreSQL\$PostgreSQLVersion\data"
$pgHba        = Join-Path $dataDir "pg_hba.conf"
$serviceName  = "postgresql-x64-$PostgreSQLVersion"
$fwRuleName   = "PostgreSQL-TCP-$Port-Privado"

# Extrair prefixo de rede da subnet para comparar IPs
$subnetBase   = ($Subnet -split "/")[0] -replace "\.\d+$", ""  # ex: 192.168.1

function Step([string]$msg)  { Write-Host "`n[*] $msg" -ForegroundColor Cyan }
function Ok([string]$msg)    { Write-Host "    [OK] $msg" -ForegroundColor Green }
function Warn([string]$msg)  { Write-Host "    [!]  $msg" -ForegroundColor Yellow }
function Fail([string]$msg)  { Write-Host "    [ERRO] $msg" -ForegroundColor Red }

# ─── Pre-requisitos ───────────────────────────────────────────────────────────

Step "Validando pre-requisitos"
if (-not (Test-Path $dataDir))   { throw "Diretorio de dados nao encontrado: $dataDir" }
if (-not (Get-Service $serviceName -ErrorAction SilentlyContinue)) {
    throw "Servico '$serviceName' nao encontrado."
}
if (-not (Test-Path $pgHba))     { throw "pg_hba.conf nao encontrado: $pgHba" }
Ok "Servico $serviceName encontrado."

# ─── 1. Perfil de rede ────────────────────────────────────────────────────────

Step "Verificando perfis de rede"

$profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue
foreach ($p in $profiles) {
    # Identifica se esta interface tem IP na subnet alvo
    $iface = $p.InterfaceAlias
    $ifaceIPs = Get-NetIPAddress -InterfaceAlias $iface -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object { $_.IPAddress -like "$subnetBase.*" }

    if ($ifaceIPs -and $p.NetworkCategory -ne "Private" -and $SetNetworkPrivate) {
        Set-NetConnectionProfile -InterfaceAlias $iface -NetworkCategory Private
        Ok "Interface '$iface' alterada para Private (era $($p.NetworkCategory))."
    } elseif ($ifaceIPs -and $p.NetworkCategory -eq "Private") {
        Ok "Interface '$iface' ja e Private."
    } elseif ($p.NetworkCategory -ne "Private") {
        Warn "Interface '$iface' e $($p.NetworkCategory) mas nao tem IP na subnet $Subnet. Ignorada."
    }
}

# ─── 2. pg_hba.conf ───────────────────────────────────────────────────────────

Step "Verificando pg_hba.conf para subnet $Subnet"

$timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item $pgHba "$pgHba.bak.$timestamp" -Force
Ok "Backup: $pgHba.bak.$timestamp"

$hbaContent = Get-Content $pgHba -Raw
$hbaEntry   = "host    all             all             $Subnet            $AuthMethod"

if ($hbaContent -match [regex]::Escape($Subnet)) {
    Warn "Entrada para $Subnet ja existe no pg_hba.conf."
} else {
    $hbaContent += "`n# Acesso remoto LAN`n$hbaEntry`n"
    Set-Content $pgHba $hbaContent -Encoding UTF8
    Ok "Entrada adicionada: $hbaEntry"
}

# ─── 3. Firewall ─────────────────────────────────────────────────────────────

Step "Configurando regra de firewall (TCP $Port, perfil Private)"

$existing = Get-NetFirewallRule -DisplayName $fwRuleName -ErrorAction SilentlyContinue

if ($existing) {
    Set-NetFirewallRule -DisplayName $fwRuleName -Profile Private -Protocol TCP -LocalPort $Port -Action Allow -Enabled True
    Warn "Regra '$fwRuleName' ja existia — atualizada."
} else {
    New-NetFirewallRule `
        -DisplayName $fwRuleName `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort $Port `
        -Profile Private `
        -Action Allow `
        -Description "PostgreSQL porta $Port - rede privada local" | Out-Null
    Ok "Regra '$fwRuleName' criada."
}

try {
    Set-NetFirewallRule -DisplayName $fwRuleName -RemoteAddress $Subnet
    Ok "RemoteAddress restrito a $Subnet."
} catch {
    Warn "Nao foi possivel restringir RemoteAddress por subnet: $_"
}

# ─── 4. Recarregar configuracao PostgreSQL ────────────────────────────────────

Step "Recarregando configuracao do PostgreSQL"

$pgBin = "C:\Program Files\PostgreSQL\$PostgreSQLVersion\bin\pg_ctl.exe"
if (Test-Path $pgBin) {
    Restart-Service -Name $serviceName -Force
    Start-Sleep -Seconds 3
    $status = (Get-Service $serviceName).Status
    if ($status -eq "Running") { Ok "Servico reiniciado. Status: $status" }
    else                       { Fail "Servico nao voltou a rodar. Status: $status" }
} else {
    Restart-Service -Name $serviceName -Force
    Start-Sleep -Seconds 3
    Ok "Servico reiniciado."
}

# ─── Resumo ───────────────────────────────────────────────────────────────────

Write-Host "`n══════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  Acesso remoto configurado." -ForegroundColor Green
Write-Host "  Subnet permitida : $Subnet" -ForegroundColor White
Write-Host "  Porta            : $Port" -ForegroundColor White
Write-Host "  Autenticacao     : $AuthMethod" -ForegroundColor White
Write-Host "  Firewall         : $fwRuleName (Private)" -ForegroundColor White
Write-Host "`n  Proximos passos:" -ForegroundColor Cyan
Write-Host "  1. .\diagnose-network.ps1    # confirmar estado" -ForegroundColor DarkYellow
Write-Host "  2. Na outra maquina: Test-NetConnection -ComputerName $env:COMPUTERNAME -Port $Port" -ForegroundColor DarkYellow
Write-Host "══════════════════════════════════════════════════════`n" -ForegroundColor Green
