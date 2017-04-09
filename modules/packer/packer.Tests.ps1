Describe "module::Packer" {
    It "installs packer" {
        "$package\tools\packer\packer.exe" | Should Exist
        packer --version | Should Be "0.12.3"
    }
}
