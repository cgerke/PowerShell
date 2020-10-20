<#
.Synopsis
  Setup PowerShell on Windows
.DESCRIPTION
  By default, the latest PowerShell release package will be installed.
  Invoke-Expression $(Invoke-WebRequest https://raw.githubusercontent.com/cgerke/PowerShell/master/install.ps1)
#>

# Install PowerShell Core
$pwshcore = $(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*  | Where-Object {$_.DisplayName -like "*PowerShell*"})
If (-not ($pwshcore)) {
  winget install --id Microsoft.PowerShell --silent
}

# Repositories
"PSGallery" | ForEach-Object -process {
  if (-not (Get-PSRepository -Name "$_")) {
    Set-PSRepository -Name "$_" -InstallationPolicy Trusted -Verbose
  }
}

# Package Provider (requires PSGallery Trust)
"Nuget" | ForEach-Object -process {
  if (-not (Get-PackageProvider -Name "$_")) {
    Install-PackageProvider -Name "$_" -Scope CurrentUser -Force -Confirm:$false -Verbose
  }
}

# Modules (Requires Nuget)
"PowerShellGet","WindowsCompatibility","Pester","PSScriptAnalyzer","Plaster","oh-my-posh","posh-git" | ForEach-Object -process {
  if (-not (Get-Module -ListAvailable -Name "$_")) {
    Install-Module "$_" -Scope CurrentUser -Force -Confirm:$false -Verbose
  }
}

# Git
$git = $(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*  | Where-Object {$_.DisplayName -like "*Git*"})
If (-not ($git)) {
  winget install --id Git.Git --silent
}

# Fetch REPO
New-Item -Path $Profile -Type File
$PSRoot = Split-Path ((Get-Item $profile).DirectoryName) -Parent
$PWShell = "$PSRoot\PowerShell"
Remove-Item -Path "$PWShell\.git" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
Remove-Item -Path $Profile -Force -Verbose -ErrorAction SilentlyContinue

<# TODO Need to investigate this further, why does this environment var
cause git init to fail? Should I just (temporarily remove HOMEPATH)
Remove-Item Env:\HOMEPATH
-or #>
New-TemporaryFile | ForEach-Object {
  Remove-Item "$_" -Force -Verbose
  New-Item -Path "$_" -ItemType Directory -Force -Verbose
  Set-Location "$_"
  Set-Item -Path Env:HOME -Value $Env:USERPROFILE
  Start-Process "git" -ArgumentList "init" -Wait -NoNewWindow
  Start-Process "git" -ArgumentList "remote add origin https://github.com/cgerke/PowerShell" -Wait -NoNewWindow
  Start-Process "git" -ArgumentList "fetch --all" -Wait -NoNewWindow
  Start-Process "git" -ArgumentList "checkout master" -Wait -NoNewWindow
  Start-Process "git" -ArgumentList "push --set-upstream origin master" -Wait -NoNewWindow
  Move-Item -Path .\.git -Destination "$PWShell\" -Force -Verbose
  Set-Location "$PWShell"
}