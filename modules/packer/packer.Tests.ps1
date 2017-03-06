Describe "module::Packer" {
    It "installs packer" {
        packer version | Should Be "Packer v0.12.3"
        "$package\tools\packer\packer.exe" | Should Exist
    }
}
