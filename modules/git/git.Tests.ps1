Describe "module::Git" {
    It "installs git" {
        git --version | Should BeLike "git version 2.12.0*"
    }
}