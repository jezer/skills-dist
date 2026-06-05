BeforeAll {
    $script:Script = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\executar-pytest-syg.ps1"
}

Describe "syg-unit-test-specialist::executar-pytest-syg.ps1" {
    It "tem param() declarado com defaults" {
        $c = Get-Content -LiteralPath $script:Script -Raw
        $c | Should -Match "(?ms)^\s*param\s*\("
        $c | Should -Match "\[string\]\`$Projeto\s*=\s*[`"']\.[`"']"
    }
    It "ErrorActionPreference Stop declarado" {
        (Get-Content -LiteralPath $script:Script -Raw) | Should -Match "ErrorActionPreference\s*=\s*[`"']Stop[`"']"
    }
    It "suporta -ComCobertura switch" {
        (Get-Content -LiteralPath $script:Script -Raw) | Should -Match "\[switch\]\`$ComCobertura"
    }
}
