Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$ExchangeVersion2019_latest = "15.2.986"
$ExchangeVersion2019_Second = "15.2.986"
$ExchangeVersion2016_latest = "15.1.2375"
$ExchangeVersion2016_Second = "15.1.2375"
$ExchangeVersion2013_latest = "15.0.1497"
$ExchangeVersion2013_Second = "15.0.1497"

$ExchangeBuildNumber = Get-ExchangeServer
$ExchangeVersion = [string]$ExchangeBuildNumber.AdminDisplayVersion.Major + "." +  [string]$ExchangeBuildNumber.AdminDisplayVersion.Minor + "." +  [string]$ExchangeBuildNumber.AdminDisplayVersion.Build


if($ExchangeBuildNumber.AdminDisplayVersion.Minor -eq 2)
{
    if($ExchangeVersion -eq $ExchangeVersion2019_latest) { $exchangeUpToDate = "2" }
    elseif($ExchangeVersion -eq $ExchangeVersion2019_second) { $exchangeUpToDate = "1" }
    else { $exchangeUpToDate = "0"}
}
if($ExchangeBuildNumber.AdminDisplayVersion.Minor -eq 1)
{
    if($ExchangeVersion -eq $ExchangeVersion2016_latest) { $exchangeUpToDate = "2" }
    elseif($ExchangeVersion -eq $ExchangeVersion2016_second) { $exchangeUpToDate = "1" }
    else{$exchangeUpToDate = "0"}
}
if($ExchangeBuildNumber.AdminDisplayVersion.Minor -eq 0)
{
    if($ExchangeVersion -eq $ExchangeVersion2013_latest) { $exchangeUpToDate = "2" }
    elseif($ExchangeVersion -eq $ExchangeVersion2013_second) { $exchangeUpToDate = "1" }
    else { $exchangeUpToDate = "0"}
}

