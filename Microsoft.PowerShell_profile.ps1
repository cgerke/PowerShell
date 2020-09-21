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

  Write-Host "$env:COMPUTERNAME " -NoNewline -ForegroundColor White
  Write-Host $ExecutionContext.SessionState.Path.CurrentLocation -ForegroundColor Gray -NoNewline
  Write-VcsStatus

  # Prompt
  "`n$('PS>' * ($nestedPromptLevel + 1)) "
}
