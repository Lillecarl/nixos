function Invoke-MySudo {
  & /usr/bin/env sudo -E pwsh -command "$args"
}

$env:SHELL = "pwsh"

Set-Alias sudo Invoke-MySudo

# Load starship
Invoke-Expression (&starship init powershell)

#Clear-Host
