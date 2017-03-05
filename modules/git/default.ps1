#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack git module
#>

Properties {
    $source = "https://github.com/git-for-windows/git/releases/download/v2.12.0.windows.1/PortableGit-2.12.0-64-bit.7z.exe"
}

FormatTaskName "Git::{0}"

Task Default -requiredVariables target -Depends Install

Task Install {
    Unpack $(Fetch $source) $(Join-Path $target tools\git)
    Copy-Item -Path .gitconfig -Destination $(Join-Path $target home)
}
