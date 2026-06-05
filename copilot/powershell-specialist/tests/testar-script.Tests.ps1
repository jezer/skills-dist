BeforeAll {
    $script:Tester = Join-Path (Split-Path $PSScriptRoot -Parent) "scripts\testar-script.ps1"
}

Describe "powershell-specialist::testar-script.ps1" {
    It "tem param Mandatory ScriptPath" {
        (Get-Content -LiteralPath $script:Tester -Raw) | Should -Match "Mandatory\s*=\s*\`$true.*ScriptPath"
    }
    It "executa script valido e retorna ExitCode 0" {
        $tmp = New-TemporaryFile
        $tmpPs = "$($tmp.FullName).ps1"
        Move-Item $tmp.FullName $tmpPs
        Set-Content -LiteralPath $tmpPs -Value "exit 0" -Encoding utf8
        try {
            $r = & $script:Tester -ScriptPath $tmpPs
            $r.Ok | Should -BeTrue
            $r.ExitCode | Should -Be 0
        } finally { Remove-Item $tmpPs -Force }
    }
    It "lanca erro se script nao existe" {
        { & $script:Tester -ScriptPath "C:\nao\existe.ps1" } | Should -Throw
    }
}
