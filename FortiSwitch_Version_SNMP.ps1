<# 
.SYNOPSIS  
Check FortiSwitch Version information based on SNMP
.DESCRIPTION 
Check FortiSwitch Version information based on SNMP
.NOTES 
Created by Barend vd Dussen 
Date: 14-11-2023
Inputs: $FortiSwitch[string], $FGTAuthSecret, $FGTPrivSecret, FGTLatestVersion_V6[String], FGTLatestVersion_V7[String], FGTLatestVersion_V74[String]
Outputs: $FortiSwitchHostname[string], $FGTInstalledVersion[string], $FGTLatestAvailableVersion[string], FGTUpToDate[String]
Version: 1.0 
Release Notes 
V1.0: Initial Setup 
#> 
# Do not prompt user for confirmations
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global


# Install PackageManagement
Install-Package -Name PackageManagement -MinimumVersion 1.4.7 -Force -Confirm:$false -Source PSGallery

# Install PowershellGet
Install-Package -Name PowershellGet -Force -Verbose

#SNMPv3 check module
$module = get-module
If ($module.name -notcontains "SNMPv3"){Install-module SNMPv3  -Force -SkipPublisherCheck -AllowClobber}
Import-Module SNMPv3

#get request for SNMP v3
$GetRequest = @{
    UserName   = 'nable'
    Target     = $FortiSwitch
    OID        = '1.3.6.1.4.1.12356.106.4.1.1.0'
    AuthType   = 'SHA1'
    AuthSecret = $FGTAuthSecret
    PrivType   = 'AES256'
    PrivSecret = $FGTPrivSecret
}

#get the FortiVersion
$FGTInstalledVersion = (Invoke-SNMPv3Get @GetRequest | Select-Object -ExpandProperty Value).toString()
$FGTInstalledVersion = $FGTInstalledVersion.Substring($FGTInstalledVersion.IndexOf(" v")+2,$FGTInstalledVersion.IndexOf(",build")-$FGTInstalledVersion.IndexOf(" v")-2)

if(($FGTInstalledVersion).StartsWith("6")){
    $FGTLatestAvailableVersion = $FGTLatestVersion_V6
}
elseif(($FGTInstalledVersion).StartsWith("7.0")){
    $FGTLatestAvailableVersion = $FGTLatestVersion_V7
}
elseif(($FGTInstalledVersion).StartsWith("7.4")){
    $FGTLatestAvailableVersion = $FGTLatestVersion_V74
}  
If(($FGTInstalledVersion -eq $FGTLatestVersion_V6) -or ($FGTInstalledVersion -eq $FGTLatestVersion_V7) -or ($FGTInstalledVersion -eq $FGTLatestVersion_V74)){
    #FortiSwitch Host up to date
    $FGTUpToDate = $FortiSwitch + " Up-To-Date"
}    
Else{
    #FortiSwitch Host not up-to-date
    $FGTUpToDate = $FortiSwitch + " Niet Up-To-Date"
}
