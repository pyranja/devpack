Describe "Module::Base" {
    It "sets Env:HOME" {
        $Env:HOME | Should Be "$package\home"
    }
    It "sets Env:TOOLS" {
        $Env:TOOLS | Should Be "$package\tools"
    }

    It "creates mount scripts" {
        "$package\Mount-Devpack.ps1" | Should Exist
        "$package\Dismount-Devpack.ps1" | Should Exist
    }
}