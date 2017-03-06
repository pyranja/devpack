#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack build script
#>

Properties {
    $version = [Version]"0.0.0"
    $zip_cmd = "7za"
    $root = $PSScriptRoot
    $workspace = $(Join-Path $root out)
    $package = $(Join-Path $workspace devpack)
}

FormatTaskName "Devpack::{0}"

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
    @("$root\base") + $(Get-ChildItem $root\modules\* -Directory) | ForEach-Object {
        Write-Verbose "including $_"
        Assert $(Test-Path $_\default.ps1) "module build script in '$_' missing"
        # perform module build
        Exec { Invoke-psake -buildFile $_\default.ps1  -parameters @{"target"="$package"} }
        # include environment partial
        If (Test-Path $_\env.partial.ps1) {
            $env_script = $(Join-Path $package Set-Env.ps1)
            "# --- env $_" | Out-File -FilePath $env_script -Encoding utf8 -Append -NoClobber
            Get-Content -Path $_\env.partial.ps1 -Encoding UTF8 | Out-File -FilePath $env_script -Encoding utf8 -Append -NoClobber
        }
    }
}

Task Test -description "run test task in a separate powershell instance." {
    powershell "Invoke-psake InlineTest -Verbose"
}

Task ? {
    Write-Host "v$version - using $zip_cmd"
}

Task InlineTest -description "run all module tests in current powershell session." {
    Write-Verbose "running integration tests"
    Assert $(Test-Path $package\Set-Env.ps1) "Set-Env.ps1 not found - is the package built?"
    Exec {
        Invoke-Expression "$package\Set-Env.ps1"
        RunIntegrationTests
    }
}

function RunIntegrationTests {
    $test_results = Join-Path $workspace test-results.xml
    Invoke-Pester -OutputFile $test_results -OutputFormat NUnitXml -EnableExit -Strict 2>$null 3>$null
    $success = $?

    If ($Env:APPVEYOR_JOB_ID) {
        $endpoint = "https://ci.appveyor.com/api/testresults/nunit/$Env:APPVEYOR_JOB_ID"
        Write-Verbose "uploading $test_results to $endpoint"
        (New-Object 'System.Net.WebClient').UploadFile($endpoint, $(Resolve-Path $test_results))
    } else {
        Write-Warning "APPVEYOR_JOB_ID not defined - skipping test result reporting"
    }

    If (-not $success) {
        Throw "test run failed"
    }
}

Task Assemble -description "Assemble the built package into a releasable archive." {
    $assembly_file = Join-Path $workspace "devpack-$version.zip"
    Write-Verbose "Assembling $assembly_file from $package"
    Assert $(Test-Path $package) "package not yet built -> run task 'Build'"
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue $assembly_file
    Compress-Archive -Path $package -DestinationPath $assembly_file -CompressionLevel Optimal -Force
}

Task CreateModule -description "Create a module stub." -requiredVariables name {
    $title = (Get-Culture).TextInfo.ToTitleCase($name.toLower())
    $module = "$root\modules\$($name.ToLower())"
    New-Item -Path "$module" -ItemType Directory
@"
# TODO
"@ | Out-File -FilePath "$module\env.partial.ps1" -Encoding utf8 -NoClobber

@"
Describe "module::$title" {
    # TODO
}
"@ | Out-File -FilePath "$module\$name.Tests.ps1" -Encoding utf8 -NoClobber

@"
#Requires -Version 5
Set-StrictMode -Version "Latest"

<#
    .SYNOPSIS devpack $title module
#>

FormatTaskName "$title::{0}"

Task Default -requiredVariables target -Depends Install

Task Install {
    # TODO
}
"@ | Out-File -FilePath "$module\default.ps1" -Encoding utf8 -NoClobber
}

# download a binary from given URL and cache it
function Fetch ($Uri) {
    $filename = Split-Path -Path $Uri -Leaf
    $cache_entry = Join-Path $workspace cache\$filename

    If (Test-Path $cache_entry) {
        return $cache_entry
    }

    # force modern TLS version, otherwise TLS 1.0 is default
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    New-Item -Path $cache_entry -ItemType File -Force | Out-Null
    Invoke-WebRequest -Uri $Uri -OutFile $cache_entry

    return $cache_entry
}

# use configured 7zip executable to unpack given binary
function Unpack ($Path, $Destination) {
    Write-Verbose "unpacking $Path >> $Destination"
    Invoke-Expression "$zip_cmd x -bd -r -y -o`"$Destination`" `"$Path`" | Out-Null"
}
