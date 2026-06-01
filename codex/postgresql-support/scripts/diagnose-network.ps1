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
$testExpected = Test-NetConnection -ComputerName $ExpectedIp -Port $Port -WarningAction SilentlyContinue
$testLocalhost = Test-NetConnection -ComputerName "localhost" -Port $Port -WarningAction SilentlyContinue

$result = [pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    DnsHostName = [System.Net.Dns]::GetHostName()
    ExpectedIp = $ExpectedIp
    ExpectedIpFound = [bool]$expected
    IPv4Addresses = @($ips | Select-Object IPAddress, InterfaceAlias, PrefixLength)
    PostgreSqlServices = @($services | Select-Object Name, Status, StartType)
    Port = $Port
    TestExpectedIp = [pscustomobject]@{
        ComputerName = $testExpected.ComputerName
        RemoteAddress = $testExpected.RemoteAddress
        TcpTestSucceeded = $testExpected.TcpTestSucceeded
    }
    TestLocalhost = [pscustomobject]@{
        ComputerName = $testLocalhost.ComputerName
        RemoteAddress = $testLocalhost.RemoteAddress
        TcpTestSucceeded = $testLocalhost.TcpTestSucceeded
    }
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result
}
