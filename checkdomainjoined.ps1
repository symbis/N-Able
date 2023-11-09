$domainState = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
$domainJoined = [int][bool]::Parse($domainState)
[string]$domainName = systeminfo | findstr /i "domain"
$domainName = $domainName.Replace("Domain:                    ","")