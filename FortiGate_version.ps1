<# 
.SYNOPSIS  
Check Fortigate Version information
.DESCRIPTION 
Check Fortigate Version information
.NOTES 
Created by Barend vd Dussen 
Date: 14-11-2023
Inputs: $FortiGate[string], $FGTapikey, $FGTport[int], FGTLatestVersion_V6[String], FGTLatestVersion_V7[String], FGTLatestVersion_V74[String]
Outputs: $FortiGateHostname[string], $FGTInstalledVersion[string], $FGTLatestAvailableVersion[string], FGTUpToDate[String]
Version: 1.0 
Release Notes 
V1.0: Initial Setup 
#> 
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#FGT check module
$module = get-module -ListAvailable
If ($module.name -notcontains "PowerFGT"){    
    # Install PackageManagement
    Install-Package -Name PackageManagement -MinimumVersion 1.4.7 -Force -Confirm:$false -Source PSGallery
    # Install PowershellGet
    Install-Package -Name PowershellGet -Force -Verbose
    #install NuGet
    Install-PackageProvider -Name NuGet -Force
    #install PowerFGT
    Install-module PowerFGT  -Force -SkipPublisherCheck -AllowClobber
}
try{
    Import-Module PowerFGT
}
catch
{
    Install-module PowerFGT  -Force -SkipPublisherCheck -AllowClobber
}

$apikey = ConvertTo-SecureString $FGTapikey -asplaintext -force
#connect to FGT
$FGT = (Connect-FGT -Server $FortiGate -ApiToken $FGTapikey -port $FGTport -SkipCertificateCheck)

[string]$FGTInstalledVersion = $FGT.version
$FortiGateHostname = (Get-FGTSystemGlobal).hostname

if(($FGTInstalledVersion).StartsWith("6")){
    $FGTLatestAvailableVersion = $FGTLatestVersion_V6
}
elseif(($FGTInstalledVersion).StartsWith("7.0")){
    $FGTLatestAvailableVersion = $FGTLatestVersion_V7
    Write-Host "Test"
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

#disconnect FGT
Disconnect-FGT -Confirm:$false
