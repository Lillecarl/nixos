function Invoke-MySudo {
  & /usr/bin/env sudo -E pwsh -command "$args"
}

$env:SHELL = "pwsh"
$env:POWERSHELL_UPDATECHECK = 'Off'

Set-Alias sudo Invoke-MySudo

# Load starship
Invoke-Expression (&starship init powershell)

