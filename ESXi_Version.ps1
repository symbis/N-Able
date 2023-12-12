<# 
.SYNOPSIS  
Check Esxi Version information
.DESCRIPTION 
Check Esxi Version information
.NOTES 
Created by Barend vd Dussen 
Date: 14-11-2023
Inputs: $VMwareHost[string], $VMwareUser[string], $VMwarePass[password], $ESXiLatestAvailableBuild_6[string], $ESXiLatestAvailableBuild_7[string], $ESXiLatestAvailableBuild_8[string],
Outputs: $ESXiHostnames[string], $ESXiInstalledVersions[string], $ESXiInstalledBuilds[string], ESXiHostsUpToDate[String], ESXiLatestAvailableBuild[string]
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

#check connected ESX hosts
$esxiServer = Get-VMHost
[string]$ESXiHostnames = $esxiServer.Name
[string]$ESXiInstalledBuilds = $esxiServer.Build
[string]$ESXiInstalledVersions = $esxiServer.Version
if(($esxiServer.Version).StartsWith("6")){
    $ESXiLatestAvailableBuild = $ESXiLatestAvailableBuild_6
}
elseif(($esxiServer.Version).StartsWith("7")){
    $ESXiLatestAvailableBuild = $ESXiLatestAvailableBuild_7
}
elseif(($esxiServer.Version).StartsWith("8")){
    $ESXiLatestAvailableBuild = $ESXiLatestAvailableBuild_8
}  
If(($esxiServer.Build -eq $ESXiLatestAvailableBuild_6) -or ($esxiServer.Build -eq $ESXiLatestAvailableBuild_7) -or ($esxiServer.Build -eq $ESXiLatestAvailableBuild_8)){
    #ESXi Host up to date
    $ESXiHostsUpToDate = $esxiServer.Name + " Up-To-Date"
}    
Else{
    #ESXi Host not up-to-date
    $ESXiHostsUpToDate = $esxiServer.Name + " Niet Up-To-Date"
}

Disconnect-VIServer -Force -Confirm:$false   