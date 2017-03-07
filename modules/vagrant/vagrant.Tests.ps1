Describe "module::Vagrant" {
    It "installs vagrant" {
        vagrant --version | Should Be "Vagrant 1.9.2"
    }
}
