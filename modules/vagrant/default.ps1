#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack Vagrant module
#>

Properties {
    $vagrant_source = "https://releases.hashicorp.com/vagrant/1.9.2/vagrant_1.9.2.msi"
}

FormatTaskName "Vagrant::{0}"

Task Default -requiredVariables target -Depends Install

Task Install {
    $installer = Fetch $vagrant_source
    # must create target folder beforehand
    $vagrant_folder = Join-Path $target tools\vagrant
    New-Item $vagrant_folder -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
    # unpack using msiexec
    $msi_args = @("/a", "`"$(Resolve-Path $installer)`"", "/qn", "TARGETDIR=`"$(Resolve-Path $vagrant_folder)`"")
    Write-Verbose "msiexec.exe $msi_args"
    Exec {
        Start-Process "msiexec.exe" -Wait -NoNewWindow -ArgumentList $msi_args
    }
    # flatten unpacked structure
    Remove-Item -Force $vagrant_folder\*.msi
    Move-Item -Path $vagrant_folder\HashiCorp\Vagrant\* -Destination $vagrant_folder -Force
    Remove-Item $vagrant_folder\HashiCorp -Recurse
}
