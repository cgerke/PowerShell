
function Set-EnvPath([string] $path ) {
  if ( -not [string]::IsNullOrEmpty($path) ) {
    if ( (Test-Path $path) -and (-not $env:PATH.contains($path)) ) {
      $env:PATH += ';' + "$path"
    }
  }
}

function Get-Telnet {
  Start-Process -FilePath powershell.exe -ArgumentList {
    -noprofile
    Get-WindowsOptionalFeature -Online -FeatureName "TelnetClient"
    Enable-WindowsOptionalFeature -Online -FeatureName "TelnetClient"
  } -verb RunAs
}
function Get-Ssh {
  Get-WindowsCapability -Online | Where-Object Name -like "OpenSSH.Client*" | Add-WindowsCapability -Online
}

function Get-Sandbox {
  Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -All -Online
}

$PSRoot = Split-Path ((Get-Item $profile).DirectoryName) -Parent

# . source
Push-Location "$PSRoot\PowerShell"
"preferences","debug" |
  Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} |
  ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"
}