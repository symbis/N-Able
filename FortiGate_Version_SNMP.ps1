<# 
.SYNOPSIS  
Check Fortigate Version information based on SNMP
.DESCRIPTION 
Check Fortigate Version information based on SNMP
.NOTES 
Created by Barend vd Dussen 
Date: 14-11-2023
Inputs: $FortiGate[string], $FGTAuthSecret, $FGTPrivSecret, FGTLatestVersion_V6[String], FGTLatestVersion_V7[String], FGTLatestVersion_V74[String]
Outputs: $FortiGateHostname[string], $FGTInstalledVersion[string], $FGTLatestAvailableVersion[string], FGTUpToDate[String]
Version: 1.0 
Release Notes 
V1.0: Initial Setup 
#> 

#SNMPv3 check module
If ($module.name -notcontains "SNMPv3"){
    if((Get-PackageProvider -Name NuGet).version -lt 2.8.5.201 )
    {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force 
    }
    Install-module SNMPv3  -Force -SkipPublisherCheck -AllowClobber
}
Import-Module SNMPv3

#get request for SNMP v3
$GetRequest = @{
    UserName   = 'nable'
    Target     = $FortiGate
    OID        = '1.3.6.1.4.1.12356.101.4.1.1.0'
    AuthType   = 'SHA1'
    AuthSecret = $FGTAuthSecret
    PrivType   = 'AES256'
    PrivSecret = $FGTPrivSecret
}

#get the FortiVersion
$FGTInstalledVersion = (Invoke-SNMPv3Get @GetRequest | Select-Object -ExpandProperty Value).toString()
$FGTInstalledVersion = $FGTInstalledVersion.Substring(1,$FGTInstalledVersion.IndexOf(",build")-1)

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
    #FortiGate Host up to date
    $FGTUpToDate = $FortiGateHostname + " Up-To-Date"
}    
Else{
    #FortiGate Host not up-to-date
    $FGTUpToDate = $FortiGateHostname + " Niet Up-To-Date"
}
