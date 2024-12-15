function Invoke-MySudo {
  & /usr/bin/env sudo -E pwsh -command "$args"
}
Set-Alias sudo Invoke-MySudo

Set-PSReadlineOption -EditMode vi

$env:POWERSHELL_UPDATECHECK = 'Off'


# Load starship
Invoke-Expression (&starship init powershell)

