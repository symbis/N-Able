<# 
.SYNOPSIS  
Check vCenter Version information
.DESCRIPTION 
Check vCenter Version information
.NOTES 
Created by Barend vd Dussen 
Date: 14-11-2023
Inputs: $VMwareHost[string], $VMwareUser[string], $VMwarePass[password], $vCenterLatestAvailableBuild_6[string], $vCenterLatestAvailableBuild_7[string], $vCenterLatestAvailableBuild_8[string]
Outputs: $vCenterHostname[string], $vCenterInstalledVersion[string], $vCenterInstalledBuild[string], $vCenterUpToDate[String], $vCenterLatestAvailableBuild[string]
Version: 1.0 
Release Notes 
V1.0: Initial Setup 
#> 

# Do not prompt user for confirmations
Set-Variable -Name 'ConfirmPreference' -Value 'None' -Scope Global
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#ESX check module
$module = get-module -ListAvailable
If ($module.name -notcontains "VMware.PowerCLI"){    
    # Install PackageManagement
    Install-Package -Name PackageManagement -MinimumVersion 1.4.7 -Force -Confirm:$false -Source PSGallery
    # Install PowershellGet
    Install-Package -Name PowershellGet -Force -Verbose
    #install NuGet
    Install-PackageProvider -Name NuGet -Force
    #install PowerCLI
    Install-module VMware.PowerCLI  -Force -SkipPublisherCheck -AllowClobber
}
try{
    Import-Module VMware.PowerCLI
}
catch
{
    Install-module VMware.PowerCLI  -Force -SkipPublisherCheck -AllowClobber
}

$VMwarePassword = ConvertTo-SecureString $VMwarePass –asplaintext –force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $VMwareUser, $VMwarePassword

#connect to VMware
$vchost = Connect-VIServer -Server $VMwareHost -Credential $Credential -Force

#Check vCenter   
$vCenterInstalledVersion = $vchost.Version
$vCenterInstalledBuild = $vchost.Build
$vCenterHostname = $vchost.Name
if(($vCenterInstalledVersion).StartsWith("6")){
    $vCenterLatestAvailableBuild = $vCenterLatestAvailableBuild_6
}
elseif(($vCenterInstalledVersion).StartsWith("7")){
    $vCenterLatestAvailableBuild = $vCenterLatestAvailableBuild_7
}
elseif(($vCenterInstalledVersion).StartsWith("8")){
    $vCenterLatestAvailableBuild = $vCenterLatestAvailableBuild_8
}    
If(($vchost.Build -eq $vCenterLatestAvailableBuild_6) -or ($vchost.Build -eq $vCenterLatestAvailableBuild_7) -or ($vchost.Build -eq $vCenterLatestAvailableBuild_8)){
    #vcenter up to date
    $vCenterUpToDate = $vCenterHostname + " Up-To-Date"       
}
Else{
    #vcenter not up-to-date
    $vCenterUpToDate = $vCenterHostname + " Niet Up-To-Date"

} 
Disconnect-VIServer -Force -Confirm:$false




