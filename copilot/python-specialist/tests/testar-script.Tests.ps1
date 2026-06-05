BeforeAll {
    $script:Tester = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\testar-script.ps1"
}

Describe "python-specialist::testar-script.ps1" {
    It "tem param Mandatory ScriptPath" {
        (Get-Content -LiteralPath $script:Tester -Raw) | Should -Match "Mandatory\s*=\s*\`$true.*ScriptPath"
    }
    It "executa script Python valido (exit 0)" {
        $tmp = New-TemporaryFile
        $tmpPy = "$($tmp.FullName).py"
        Move-Item $tmp.FullName $tmpPy
        Set-Content -LiteralPath $tmpPy -Value "raise SystemExit(0)" -Encoding utf8
        try {
            $r = & $script:Tester -ScriptPath $tmpPy
            $r.Ok | Should -BeTrue
        } finally { Remove-Item $tmpPy -Force }
    }
    It "lanca erro se script nao existe" {
        { & $script:Tester -ScriptPath "C:\nao\existe.py" } | Should -Throw
    }
}
