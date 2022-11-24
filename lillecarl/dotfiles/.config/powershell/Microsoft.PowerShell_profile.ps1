function Invoke-MySudo {
  & /usr/bin/env sudo -E pwsh -command "$args"
}

set-alias sudo Invoke-MySudo

# Load starship
Get-Command -ErrorAction SilentlyContinue -Name kubectl | Out-Null && kubectl completion powershell | Out-String | Invoke-Expression
Get-Command -ErrorAction SilentlyContinue -Name starship | Out-Null && starship init powershell | Out-String | Invoke-Expression
#Invoke-Expression (&starship init powershell)

#Clear-Host
