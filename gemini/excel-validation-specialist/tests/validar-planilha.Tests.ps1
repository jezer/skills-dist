BeforeAll {
    $script:Validator = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\validar-planilha.ps1"
}

Describe "excel-validation-specialist::validar-planilha.ps1" {
    It "valida CSV minimo com colunas certas" {
        $tmp = New-TemporaryFile
        $csv = "$($tmp.FullName).csv"
        Move-Item $tmp.FullName $csv
        Set-Content -LiteralPath $csv -Value "id,nome`n1,Alice`n2,Bob" -Encoding utf8
        try {
            $r = & $script:Validator -Arquivo $csv -ColunasObrigatorias id,nome -LinhasMin 1
            $r.Ok | Should -BeTrue
            $r.Linhas | Should -Be 2
            $r.ColunasFaltantes.Count | Should -Be 0
        } finally { Remove-Item $csv -Force }
    }
    It "marca coluna faltante" {
        $tmp = New-TemporaryFile
        $csv = "$($tmp.FullName).csv"
        Move-Item $tmp.FullName $csv
        Set-Content -LiteralPath $csv -Value "id,nome`n1,Alice" -Encoding utf8
        try {
            $r = & $script:Validator -Arquivo $csv -ColunasObrigatorias id,nome,idade
            $r.Ok | Should -BeFalse
            $r.ColunasFaltantes | Should -Contain "idade"
        } finally { Remove-Item $csv -Force }
    }
    It "rejeita extensao nao suportada" {
        $tmp = New-TemporaryFile
        $bad = "$($tmp.FullName).txt"
        Move-Item $tmp.FullName $bad
        Set-Content -LiteralPath $bad -Value "x" -Encoding utf8
        try {
            { & $script:Validator -Arquivo $bad -ColunasObrigatorias x } | Should -Throw
        } finally { Remove-Item $bad -Force }
    }
}
