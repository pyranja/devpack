#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack base module
#>

FormatTaskName "base::{0}"

Task Default -requiredVariables target -depends Install

Task Install {
    @("Mount-Devpack.ps1", "Dismount-Devpack.ps1") | ForEach-Object { Copy-Item -Path $_ -Destination $target }
}
