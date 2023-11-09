#user settings Fortigate
$fw = "10.0.0.253"
$port = "8443"
$FGTuser = "admin"
$FGTpass = ConvertTo-SecureString {password} –asplaintext –force

#latest FortiOS
$fwlatest = "6.4.5"

#latest exchange builds
$2019latest = "15.2.792.3"
$2016latest = "15.1.2176.2"
$2013latest = "15.0.1497.2"

#settings - Do not change!
$hostname = hostname
$module = get-module
$infofile = get-item -path "\\$hostname\c$\aenc\softwareversions\Software_versions.txt"
$filter = (Get-ADObject -Filter 'msExchCapabilityIdentifiers -eq "1"')
$EXserver = $filter.name
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Create file to add software version information
New-item -ItemType "file" -path "C:\aenc\softwareversions\" -name "Software_versions.txt" -Force

#FGT check module
If ($module.name -notcontains "PowerFGT"){
Install-module PowerFGT}
Import-Module PowerFGT

#connect to FGT
$FGT = (Connect-FGT -Username $FGTuser -Password $FGTpass -server $fw -port $port -SkipCertificateCheck)

$FGTVersion = $FGT.version
$fwhost = Get-FGTSystemGlobal
$fwname = $fwhost.hostname
if($FGTVersion -lt $fwlatest){$fwupdate = "Software niet op de laatste release ($fwlatest)"}
else{$fwupdate = "Software Up-to-date"}

Add-Content $infofile $fwname
Add-Content $infofile $FGTVersion
Add-content $infofile $fwupdate

#disconnect FGT
Disconnect-FGT -Confirm:$false
Add-Content $infofile ""


#Exchange check module
If($module.name -notcontains "ActiveDirectory"){
Install-Module -Name ActiveDirectory}
Import-Module ActiveDirectory

#Check installed exchange version(s)
$filter = (Get-ADObject -Filter 'msExchCapabilityIdentifiers -eq "1"')
$EXserver = $filter.name


foreach($server in $EXserver){
add-content $infofile $server

$exchange = (Get-WmiObject -ComputerName $server -Class Win32_Product | Where Name -eq "Microsoft Exchange Server")
$Exver = $exchange.version
$Ex2019latest = $2019latest
$Ex2016latest = $2016latest
$Ex2013latest = $2013latest

If($Exver -gt "15.2.0.0"){
if($Exver -lt $Ex2019latest){$update = "Exchange 2019 niet op de laatste CU"}
Else{$update = "Exchange 2019 Up-to-date"}}
Elseif($Exver -gt "15.1.0.0"){
if($Exver -lt $Ex2016latest){$update = "Exchange 2016 niet op de laatste CU"}
Else{$update = "Exchange 2016 Up-to-date"}}
Elseif($Exver -gt "15.0.0.0"){
if($Exver -lt $Ex2013latest){$update = "Exchange 2013 niet op de laatste CU"}
Else{$update = "Exchange 2013 Up-to-date"}}
Else{$Exver = $Exver}

Add-Content $infofile $Exver
Add-Content $infofile $update
}
