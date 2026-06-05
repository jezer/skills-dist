BeforeAll {
    $script:SkillDir = Split-Path -Parent $PSScriptRoot
    $script:SkillMd  = Join-Path $script:SkillDir "SKILL.md"
}

Describe "architecture-diagrammer structure" {
    It "tem SKILL.md sem BOM" {
        $bytes = [System.IO.File]::ReadAllBytes($script:SkillMd)
        $bytes[0] | Should -Not -Be 0xEF
    }
    It "frontmatter comeca com ---" {
        (Get-Content -LiteralPath $script:SkillMd -TotalCount 1) | Should -Be "---"
    }
    It "tem name correto" {
        (Get-Content -LiteralPath $script:SkillMd -Raw) | Should -Match "(?m)^name:\s*architecture-diagrammer\s*$"
    }
    It "tem description nao-vazia" {
        (Get-Content -LiteralPath $script:SkillMd -Raw) | Should -Match "description:\s*.{20,}"
    }
}
