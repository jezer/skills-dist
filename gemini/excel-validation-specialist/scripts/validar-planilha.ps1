param(
    [Parameter(Mandatory = $true)][string]$Arquivo,
    [string]$Sheet,
    [string[]]$ColunasObrigatorias,
    [int]$LinhasMin = 1
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Arquivo)) {
    throw "Arquivo nao encontrado: $Arquivo"
}

$ext = [IO.Path]::GetExtension($Arquivo).ToLower()
if ($ext -notin @(".xlsx", ".xlsm", ".csv")) {
    throw "Formato nao suportado: $ext (use .xlsx, .xlsm ou .csv)"
}

if ($ext -eq ".csv") {
    $linhas = @(Import-Csv -LiteralPath $Arquivo)
    $colunas = if ($linhas.Count -gt 0) { $linhas[0].PSObject.Properties.Name } else { @() }
} else {
    # Para xlsx/xlsm, delegar para python (openpyxl) se disponivel
    $py = Get-Command python -ErrorAction SilentlyContinue
    if (-not $py) { throw "Python necessario para validar xlsx/xlsm" }
    $sheetArg = if ($Sheet) { "--sheet `"$Sheet`"" } else { "" }
    $tmp = New-TemporaryFile
    try {
        $cmd = @"
import json, openpyxl, sys
wb = openpyxl.load_workbook(r'$Arquivo', read_only=True, data_only=True)
ws = wb['$Sheet'] if '$Sheet' else wb.active
rows = list(ws.iter_rows(values_only=True))
cols = list(rows[0]) if rows else []
print(json.dumps({'colunas': cols, 'linhas': len(rows) - 1 if rows else 0}))
"@
        $out = python -c $cmd 2>&1
        $r = $out | ConvertFrom-Json
        $colunas = $r.colunas
        $linhasCount = $r.linhas
        $linhas = (1..$linhasCount)
    } finally { Remove-Item $tmp.FullName -Force -ErrorAction SilentlyContinue }
}

$faltantes = @()
foreach ($c in $ColunasObrigatorias) {
    if ($c -notin $colunas) { $faltantes += $c }
}

$ok = ($faltantes.Count -eq 0) -and ($linhas.Count -ge $LinhasMin)

[pscustomobject]@{
    Arquivo             = $Arquivo
    Sheet               = $Sheet
    Colunas             = $colunas
    Linhas              = $linhas.Count
    ColunasFaltantes    = $faltantes
    LinhasMinAtingido   = ($linhas.Count -ge $LinhasMin)
    Ok                  = $ok
}
