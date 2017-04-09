Describe "module::Vagrant" {
    It "installs vagrant" {
        "$package\tools\vagrant\bin\vagrant.exe" | Should Exist
        vagrant --version | Should Be "Vagrant 1.9.2"
    }
}
