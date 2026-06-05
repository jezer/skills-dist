BeforeAll {
    $script:Script = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\regenerar-cabecalho.ps1"
    $script:Config = Join-Path (Split-Path $PSScriptRoot -Parent) "config\semaforo.json"
}

Describe "semaforo-cabecalho::regenerar-cabecalho.ps1" {
    It "tem param Versao e ConfigOverride" {
        $c = Get-Content -LiteralPath $script:Script -Raw
        $c | Should -Match "\[string\]\`$Versao"
        $c | Should -Match "\[string\]\`$ConfigOverride"
    }
    It "config semaforo.json existe e e valido" {
        Test-Path $script:Config | Should -BeTrue
        $j = Get-Content -LiteralPath $script:Config -Raw | ConvertFrom-Json
        $j.tabela | Should -Be "tb_semaforo_cabecalho"
        $j.output_dir | Should -Be "C:/codes/pv/semaforo/cabecalho/scripts/output"
        $j.filtros | Should -Contain "lib_createobj"
        $j.fontes.Count | Should -BeGreaterThan 10
    }
    It "config aponta para code-parquet-builder" {
        (Get-Content -LiteralPath $script:Script -Raw) | Should -Match "code-parquet-builder"
    }
}
