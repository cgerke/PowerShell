$PSRoot = Split-Path ((Get-Item $profile).DirectoryName) -Parent

# . source
Push-Location "$PSRoot\PowerShell"
"preferences","debug" |
  Where-Object {Test-Path "Microsoft.PowerShell_$_.ps1"} |
  ForEach-Object -process {
    Invoke-Expression ". .\Microsoft.PowerShell_$_.ps1"
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

function Test-IsAdmin {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
  # Powershell version
  $PSVersionTable.PSVersion |
    ForEach-Object -process { "$_ " } |
    Write-Host -NoNewLine -ForegroundColor Cyan
  Write-Host $(Get-ExecutionPolicy) -NoNewline -ForegroundColor Cyan

  # User
  if (Test-IsAdmin) {  # if elevated
    Write-Host " (Elevated $env:USERNAME ) " -NoNewline -ForegroundColor Red
  } else {
    Write-Host " $env:USERNAME " -NoNewline -ForegroundColor White
  }

  # Host
  Write-Host "$env:COMPUTERNAME " -NoNewline -ForegroundColor White
  Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Gray -NoNewline
  Write-VcsStatus

  # Prompt
  "`n$('PS>' * ($nestedPromptLevel + 1)) "
}
