BeforeAll {
    $script:Validator = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\validar-sql.ps1"
}

Describe "redshift-sql-specialist::validar-sql.ps1" {
    It "aceita SELECT simples" {
        $r = & $script:Validator -Sql "SELECT 1 FROM tabela"
        $r.Ok | Should -BeTrue
    }
    It "rejeita DML quando flag setada" {
        $r = & $script:Validator -Sql "UPDATE tabela SET x=1" -RejeitarDml
        $r.Ok | Should -BeFalse
        $r.DmlDetectado | Should -Contain "UPDATE"
    }
    It "rejeita DDL quando flag setada" {
        $r = & $script:Validator -Sql "DROP TABLE tabela" -RejeitarDdl
        $r.Ok | Should -BeFalse
        $r.DdlDetectado | Should -Contain "DROP"
    }
    It "detecta parenteses desbalanceados" {
        $r = & $script:Validator -Sql "SELECT (a + b FROM tabela"
        $r.Ok | Should -BeFalse
        $r.Razao | Should -Match "Parenteses desbalanceados"
    }
    It "ignora DML em comentario" {
        $r = & $script:Validator -Sql "-- UPDATE tabela`nSELECT 1" -RejeitarDml
        $r.Ok | Should -BeTrue
    }
}
