param(
    [Parameter(Mandatory = $true, ParameterSetName="File")][string]$Arquivo,
    [Parameter(Mandatory = $true, ParameterSetName="Sql")][string]$Sql,
    [switch]$RejeitarDml,
    [switch]$RejeitarDdl
)

$ErrorActionPreference = "Stop"

if ($PSCmdlet.ParameterSetName -eq "File") {
    if (-not (Test-Path -LiteralPath $Arquivo)) { throw "Arquivo nao encontrado: $Arquivo" }
    $Sql = Get-Content -LiteralPath $Arquivo -Raw
}

if ([string]::IsNullOrWhiteSpace($Sql)) {
    return [pscustomobject]@{
        Ok = $false
        Razao = "SQL vazio"
    }
}

$normalizado = $Sql -replace "--[^\n]*", "" -replace "/\*[\s\S]*?\*/", ""
$upper = $normalizado.ToUpper()

$dmlVerbs = @("INSERT", "UPDATE", "DELETE", "MERGE", "COPY")
$ddlVerbs = @("CREATE", "ALTER", "DROP", "TRUNCATE", "GRANT", "REVOKE", "RENAME")

$dmlEncontrados = @($dmlVerbs | Where-Object { $upper -match "\b$_\b" })
$ddlEncontrados = @($ddlVerbs | Where-Object { $upper -match "\b$_\b" })

$razoes = @()
if ($RejeitarDml -and $dmlEncontrados.Count -gt 0) { $razoes += "DML rejeitado: $($dmlEncontrados -join ',')" }
if ($RejeitarDdl -and $ddlEncontrados.Count -gt 0) { $razoes += "DDL rejeitado: $($ddlEncontrados -join ',')" }

# Detec verificacao basica de balanceamento parenteses
$abre = ([regex]::Matches($Sql, "\(")).Count
$fecha = ([regex]::Matches($Sql, "\)")).Count
if ($abre -ne $fecha) { $razoes += "Parenteses desbalanceados ($abre x $fecha)" }

[pscustomobject]@{
    Ok                = ($razoes.Count -eq 0)
    Razao             = $razoes -join "; "
    DmlDetectado      = $dmlEncontrados
    DdlDetectado      = $ddlEncontrados
    ParentesesAbre    = $abre
    ParentesesFecha   = $fecha
    CaracteresLimpos  = $normalizado.Length
}
