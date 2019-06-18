# PowerShell $profile
## Installation
```
Invoke-Expression $(Invoke-WebRequest https://raw.githubusercontent.com/cgerke/PowerShell/master/install.ps1)
```
## Setup
Add a custom Microsoft.PowerShell_Preferences.ps1 file with 'defaults'
```
$global:Default = [pscustomobject]@{
    Username = 'YOURUSERNAME'
}
```
