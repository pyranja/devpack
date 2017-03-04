#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack build script
#>

Properties {
    $version = [Version]"0.0.0"
    $assembly = "devpack-$version.zip"
    $zip_cmd = "7za"
    $root = $PSScriptRoot
    $workspace = Join-Path $root out
    $package = Join-Path $workspace pkg
}

Task Default -Depends Build, Assemble

Task Clean -description "Delete the build workspace, including all cached binaries." {
    Write-Verbose "Removing $workspace"
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue $workspace
}

Task Build -description "Apply all included modules to the workspace package." -preaction {
    Remove-Item -Path $package -Recurse -ErrorAction SilentlyContinue
    New-Item -Path $package -ItemType Directory -Force | Out-Null
    @("home", "tools") | ForEach-Object { New-Item -Path $package\$_ -ItemType Directory -Force | Out-Null }
} {
    @("$root\base") + $(Get-ChildItem $root\modules\*) | ForEach-Object {
        Write-Verbose "including $_"
        Assert $(Test-Path $_\default.ps1) "module build script in '$_' missing"
        # perform module build
        Exec { Invoke-psake -buildFile $_\default.ps1  -parameters @{"target"="$package"} }
        # include environment partial
        If (Test-Path $_\env.partial.ps1) {
            Get-Content -Path $_\env.partial.ps1 -Encoding UTF8 | Out-File -FilePath $(Join-Path $package Set-Env.ps1) -Encoding utf8 -Append -NoClobber
        }
    }
}

Task Test -description "Run all module integration tests." {
    Write-Verbose "running integration tests"
    Assert $(Test-Path $package\Set-Env.ps1) "Set-Env.ps1 not found - is the package built?"
    Invoke-Expression "$package\Set-Env.ps1"
    Invoke-Pester
}

Task Assemble -description "Assemble the built package into a releasable archive." {
    $assembly_file = Join-Path $workspace $assembly
    Write-Verbose "Assembling $assembly_file from $package"
    Assert $(Test-Path $package) "package not yet built -> run task 'Build'"
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue $assembly_file
    Compress-Archive -Path $package\* -DestinationPath $assembly_file -CompressionLevel Optimal -Force
}

# download a binary from given URL and cache it
function Fetch ($Uri) {
    $filename = Split-Path -Path $Uri -Leaf
    $cache_entry = Join-Path $workspace cache\$filename

    If (Test-Path $cache_entry) {
        return $cache_entry
    }

    New-Item -Path $cache_entry -ItemType File -Force | Out-Null
    Invoke-WebRequest -Uri $Uri -OutFile $cache_entry

    return $cache_entry
}

# use configured 7zip executable to unpack given binary
function Unpack ($Path, $Destination) {
    Invoke-Expression "$zip_cmd x -bd -r -y -o`"$Destination`" `"$Path`""
}
