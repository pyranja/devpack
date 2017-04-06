# devpack

[![Build Status](https://ci.appveyor.com/api/projects/status/github/pyranja/devpack)](https://ci.appveyor.com/project/pyranja/devpack)
[![License](https://img.shields.io/badge/license-GPL--3.0%2B-blue.svg)](https://www.gnu.org/licenses/gpl-3.0.txt)

A port of the [devpack](https://github.com/Zuehlke/z-devpack) concept to a pure powershell build system.

## Contributing

### Prerequisites

Install [psake](https://github.com/psake/psake), [pester](https://github.com/pester/Pester) and [7-zip](http://www.7-zip.org/):

    choco install -y 7-zip
    Install-Module psake
    Install-Module pester

### Adding a new Module

Run

    Invoke-psake CreateModule -Verbose -parameters @{name = '<module-name>'}

That task creates a new subfolder in ./modules/ and prepares

* a psake module build file (default.ps1)
* a pester test file
* a partial evironment variable definition

## License

Copyright (C) 2017 Chris Borckholder

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
