BeforeAll {
    $script:Runner = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\run-query-rules-comparison.ps1"
}

Describe "redshift-query-rules-comparator::run-query-rules-comparison.ps1" {
    It "retorna configuracao em DryRun" {
        $old = Join-Path $TestDrive "old.sql"
        $new = Join-Path $TestDrive "new.sql"
        $cmp = Join-Path $TestDrive "compare_sql_rules.py"

        Set-Content -LiteralPath $old -Value "select 1 as c from t;"
        Set-Content -LiteralPath $new -Value "select 1 as c from t;"
        Set-Content -LiteralPath $cmp -Value "print('ok')"

        $r = & $script:Runner -SqlOld $old -SqlNew $new -ComparatorPythonScript $cmp -LogsDir $TestDrive -DryRun
        $r.DryRun | Should -BeTrue
        $r.SqlOld | Should -Be $old
        $r.SqlNew | Should -Be $new
    }
}
