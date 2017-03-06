Describe "module::Conemu" {
    It "installs conemu" {
        ConEmu64.exe -Exit
        $? | Should Be $true
    }
    It "unpacks conemu binary" {
        "$package\tools\ConEmu\ConEmu64.exe" | Should Exist
        "$package\tools\ConEmu\ConEmu.exe" | Should Exist
    }
}
