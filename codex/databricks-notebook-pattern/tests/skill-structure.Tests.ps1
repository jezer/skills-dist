BeforeAll {
    $script:SkillDir = Split-Path -Parent $PSScriptRoot
    $script:SkillMd  = Join-Path $script:SkillDir "SKILL.md"
}

Describe "databricks-notebook-pattern structure" {
    It "tem SKILL.md sem BOM" {
        $bytes = [System.IO.File]::ReadAllBytes($script:SkillMd)
        $bytes[0] | Should -Not -Be 0xEF
    }
    It "frontmatter comeca com ---" {
        (Get-Content -LiteralPath $script:SkillMd -TotalCount 1) | Should -Be "---"
    }
    It "tem name e description no frontmatter" {
        $head = Get-Content -LiteralPath $script:SkillMd -TotalCount 10
        ($head -join "`n") | Should -Match "name:\s*databricks-notebook-pattern"
        ($head -join "`n") | Should -Match "description:\s*\S"
    }
    It "tem ## Objetivo" {
        (Get-Content -LiteralPath $script:SkillMd -Raw) | Should -Match "## Objetivo"
    }
}
