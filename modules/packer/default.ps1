#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack Packer module
#>

Properties {
    $packer_source = "https://releases.hashicorp.com/packer/0.12.3/packer_0.12.3_windows_amd64.zip"
}

FormatTaskName "Packer::{0}"

Task Default -requiredVariables target -Depends Install

Task Install {
    Unpack $(Fetch $packer_source) $(Join-Path $target tools\packer) 
}
