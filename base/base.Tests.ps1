Describe "module::base" {
    It "sets Env:HOME" {
        $Env:HOME | Should Be "$package\home"
    }

    It "creates mount scripts" {
        "$package\Mount-Devpack.ps1" | Should Exist
        "$package\Dismount-Devpack.ps1" | Should Exist
    }
}