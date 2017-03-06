#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack Conemu module
#>

Properties {
    $conemu_source = "https://github.com/Maximus5/ConEmu/releases/download/v17.03.05/ConEmuPack.170305.7z"
}

FormatTaskName "Conemu::{0}"

Task Default -requiredVariables target -Depends Install

Task Install {
    Unpack $(Fetch $conemu_source) $(Join-Path $target tools\ConEmu)
    # remove unused far plugin
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $(Join-Path $target tools\ConEmu\plugins)
}
