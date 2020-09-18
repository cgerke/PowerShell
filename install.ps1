 [cmdletbinding()]
 Param()

<#
.Synopsis
  Setup PowerShell $profile on Windows
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
    Set-PSRepository -Name "$_" -InstallationPolicy Trusted -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  }
}

# Package Provider (requires PSGallery Trust)
"Nuget" | ForEach-Object -process {
  if (-not (Get-PackageProvider -Name "$_")) {
    Install-PackageProvider -Name "$_" -Scope CurrentUser -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  }
}

# Modules (Requires Nuget)
"PowerShellGet","WindowsCompatibility","Pester","PSScriptAnalyzer","Plaster","posh-git" | ForEach-Object -process {
  if (-not (Get-Module -ListAvailable -Name "$_")) {
    Install-Module "$_" -Scope CurrentUser -Force -Confirm:$false -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  }
}

# Git
$git = $(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*  | Where-Object {$_.DisplayName -like "*Git*"})
If (-not ($git)) {
  winget install --id Git.Git --silent
}

# Fetch REPO
$PSUser = Split-Path ((Get-Item $profile).DirectoryName) -Parent
$PWShell = "$PSUser\PowerShell"
Remove-Item -Path "$PWShell\.git" -Recurse -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true) -ErrorAction SilentlyContinue

<# TODO Need to investigate this further, why does this environment var
cause git init to fail? Should I just (temporarily remove HOMEPATH)
Remove-Item Env:\HOMEPATH
-or #>
New-TemporaryFile | ForEach-Object {
  Remove-Item "$_" -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  New-Item -Path "$_" -ItemType Directory -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true) 
  Set-Location "$_" -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  Set-Item -Path Env:HOME -Value $Env:USERPROFILE -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  git init
  Move-Item -Path .\.git -Destination "$PWShell\" -Force -Verbose:($PSBoundParameters['Verbose'] -eq $true)
  Set-Location "$PWShell"
  & git remote add origin https://github.com/cgerke/PowerShell
  & git fetch --all
  & git checkout master
}

<# One profile to rule them all? This is annoying though, have to elevate
 to create symoblic links.

New-Item -ItemType SymbolicLink `
  -Path "$PWShell\" `
  -Name "Microsoft.PowerShell_profile.ps1" `
  -Target "$PWShell\Microsoft.PowerShell_profile.ps1"
#>
