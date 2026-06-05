BeforeAll {
    $script:SkillDir = Split-Path -Parent $PSScriptRoot
    $script:SkillMd  = Join-Path $script:SkillDir "SKILL.md"
    $script:ScriptsDir = Join-Path $script:SkillDir "scripts"
}

Describe "sync-repositories-index structure" {
    It "tem SKILL.md sem BOM" {
        $bytes = [System.IO.File]::ReadAllBytes($script:SkillMd)
        $bytes[0] | Should -Not -Be 0xEF
    }
    It "frontmatter comeca com ---" {
        (Get-Content -LiteralPath $script:SkillMd -TotalCount 1) | Should -Be "---"
    }
    It "tem name correto" {
        (Get-Content -LiteralPath $script:SkillMd -Raw) | Should -Match "(?m)^name:\s*sync-repositories-index\s*$"
    }
    It "tem 3 scripts esperados" {
        Test-Path (Join-Path $script:ScriptsDir "gerar-indice-local.ps1")    | Should -BeTrue
        Test-Path (Join-Path $script:ScriptsDir "validar-indice-local.ps1")  | Should -BeTrue
        Test-Path (Join-Path $script:ScriptsDir "resumo-sincronizacao.ps1")  | Should -BeTrue
    }
}
