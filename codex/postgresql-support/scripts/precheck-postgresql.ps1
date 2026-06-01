param(
    [string]$ExpectedIp = "192.168.1.10",
    [int]$Port = 5432,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Get-CommandStatus {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [string[]]$CandidatePaths = @()
    )
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    $candidate = $CandidatePaths | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    [pscustomobject]@{
        Name = $Name
        Found = [bool]($cmd -or $candidate)
        Path = if ($cmd) { $cmd.Source } elseif ($candidate) { $candidate } else { $null }
    }
}

$os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
$ipMatch = Get-NetIPAddress -IPAddress $ExpectedIp -ErrorAction SilentlyContinue
$portListeners = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
    Where-Object { $_.State -eq "Listen" -or $_.State -eq "Established" }
$profiles = Get-NetConnectionProfile -ErrorAction SilentlyContinue

$dbeaverCandidates = @(
    "C:\Program Files\DBeaver\dbeaver.exe",
    "C:\Program Files\DBeaver Community\dbeaver.exe",
    "$env:LOCALAPPDATA\DBeaver\dbeaver.exe"
) | Where-Object { Test-Path -LiteralPath $_ }

$result = [pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    WindowsCaption = if ($os) { $os.Caption } else { $null }
    WindowsVersion = if ($os) { $os.Version } else { $null }
    PowerShellVersion = $PSVersionTable.PSVersion.ToString()
    Commands = @(
        Get-CommandStatus -Name "choco"
        Get-CommandStatus -Name "winget"
        Get-CommandStatus -Name "psql" -CandidatePaths @(
            "C:\Program Files\PostgreSQL\18\bin\psql.exe",
            "C:\Program Files\PostgreSQL\17\bin\psql.exe",
            "C:\Program Files\PostgreSQL\16\bin\psql.exe"
        )
        Get-CommandStatus -Name "pg_dump" -CandidatePaths @(
            "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe",
            "C:\Program Files\PostgreSQL\17\bin\pg_dump.exe",
            "C:\Program Files\PostgreSQL\16\bin\pg_dump.exe"
        )
    )
    DBeaverFound = [bool]$dbeaverCandidates
    DBeaverPaths = $dbeaverCandidates
    ExpectedIp = $ExpectedIp
    ExpectedIpFound = [bool]$ipMatch
    ExpectedIpInterfaces = @($ipMatch | Select-Object IPAddress, InterfaceAlias, PrefixLength, AddressFamily)
    Port = $Port
    PortInUse = [bool]$portListeners
    PortConnections = @($portListeners | Select-Object LocalAddress, LocalPort, State, OwningProcess)
    NetworkProfiles = @($profiles | Select-Object Name, InterfaceAlias, NetworkCategory, IPv4Connectivity)
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    $result
}
