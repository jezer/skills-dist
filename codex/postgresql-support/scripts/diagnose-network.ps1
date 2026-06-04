param(
    [string]$ExpectedIp = "192.168.1.10",
    [int]$Port = 5432,
    [string]$ServiceNamePattern = "postgresql*",
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
    Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1" }

$expected = $ips | Where-Object { $_.IPAddress -eq $ExpectedIp }

$services = Get-Service -Name $ServiceNamePattern -ErrorAction SilentlyContinue

$testExpected  = Test-NetConnection -ComputerName $ExpectedIp  -Port $Port -WarningAction SilentlyContinue
$testLocalhost = Test-NetConnection -ComputerName "localhost"  -Port $Port -WarningAction SilentlyContinue

# Perfil de rede por interface — critico para regras de firewall com Profile:Private
$netProfiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue |
    Select-Object Name, NetworkCategory, InterfaceAlias

# Firewall: regras ativas para a porta
$fwRules = Get-NetFirewallRule -Direction Inbound -Action Allow -Enabled True -ErrorAction SilentlyContinue |
    Get-NetFirewallPortFilter |
    Where-Object { $_.LocalPort -eq "$Port" } |
    ForEach-Object {
        $r = $_ | Get-NetFirewallRule
        [pscustomobject]@{
            DisplayName = $r.DisplayName
            Profile     = $r.Profile
            Enabled     = $r.Enabled
        }
    }

$result = [pscustomobject]@{
    ComputerName      = $env:COMPUTERNAME
    DnsHostName       = [System.Net.Dns]::GetHostName()
    ExpectedIp        = $ExpectedIp
    ExpectedIpFound   = [bool]$expected
    IPv4Addresses     = @($ips | Select-Object IPAddress, InterfaceAlias, PrefixLength)
    NetworkProfiles   = @($netProfiles)
    PostgreSqlServices = @($services | Select-Object Name, Status, StartType)
    Port              = $Port
    FirewallRules     = @($fwRules)
    TestExpectedIp    = [pscustomobject]@{
        ComputerName     = $testExpected.ComputerName
        RemoteAddress    = $testExpected.RemoteAddress
        TcpTestSucceeded = $testExpected.TcpTestSucceeded
    }
    TestLocalhost     = [pscustomobject]@{
        ComputerName     = $testLocalhost.ComputerName
        RemoteAddress    = $testLocalhost.RemoteAddress
        TcpTestSucceeded = $testLocalhost.TcpTestSucceeded
    }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    # Exibicao formatada
    $sep = "-" * 55
    Write-Host "`n$sep"
    Write-Host "  DIAGNOSTICO POSTGRESQL - $($result.ComputerName)"
    Write-Host $sep

    Write-Host "`n[Interfaces IPv4]"
    foreach ($ip in $result.IPv4Addresses) {
        Write-Host ("  {0,-18} {1}/{2}" -f $ip.IPAddress, $ip.InterfaceAlias, $ip.PrefixLength)
    }

    Write-Host "`n[Perfis de rede - critico para firewall]"
    foreach ($p in $result.NetworkProfiles) {
        $cor = if ($p.NetworkCategory -eq "Private") { "Green" } else { "Yellow" }
        $linha = "  {0,-20} {1,-12} {2}" -f $p.InterfaceAlias, $p.NetworkCategory, $p.Name
        Write-Host $linha -ForegroundColor $cor
    }
    $publicIfaces = $result.NetworkProfiles | Where-Object { $_.NetworkCategory -ne "Private" }
    if ($publicIfaces) {
        Write-Host "  [!] Interfaces Public/Domain ignoram regras de firewall com Profile:Private." -ForegroundColor Red
        Write-Host "      Corrija: Set-NetConnectionProfile -InterfaceAlias '<nome>' -NetworkCategory Private" -ForegroundColor Yellow
    }

    Write-Host "`n[Servico PostgreSQL]"
    foreach ($s in $result.PostgreSqlServices) {
        $cor = if ($s.Status -eq "Running") { "Green" } else { "Red" }
        Write-Host ("  {0} — {1}" -f $s.Name, $s.Status) -ForegroundColor $cor
    }

    Write-Host "`n[Firewall - porta $Port]"
    if ($result.FirewallRules) {
        foreach ($r in $result.FirewallRules) {
            Write-Host ("  [OK] {0} | Perfil: {1}" -f $r.DisplayName, $r.Profile) -ForegroundColor Green
        }
    } else {
        Write-Host "  [!] Nenhuma regra ativa para TCP $Port." -ForegroundColor Red
    }

    Write-Host "`n[Conectividade porta $Port]"
    $cor = if ($result.TestLocalhost.TcpTestSucceeded)  { "Green" } else { "Red" }
    Write-Host ("  localhost   : {0}" -f $result.TestLocalhost.TcpTestSucceeded)  -ForegroundColor $cor
    $cor = if ($result.TestExpectedIp.TcpTestSucceeded) { "Green" } else { "Red" }
    Write-Host ("  {0,-12}: {1}" -f $ExpectedIp, $result.TestExpectedIp.TcpTestSucceeded) -ForegroundColor $cor
    Write-Host ""
}
