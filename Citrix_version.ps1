<# 
.SYNOPSIS  
Check Citrix Version information
.DESCRIPTION 
Check Citrix Version information
.NOTES 
Created by Barend vd Dussen 
Date: 15-11-2023
Inputs: $LatestAvailableVersion[string]
Outputs: $InstalledVersion[string], $VersionUptoDate[string]
Version: 1.0 
Release Notes 
V1.0: Initial Setup 
#> 

#get Citrix Storefront Version
[string]$InstalledVersion = (Get-Item $citrixPath).VersionInfo.FileVersionRaw
Write-Host $InstalledVersion

#check if Version is up-to-date.
if($InstalledVersion -like "*$LatestAvailableVersion*"){
    #Version up-to-date.
    $VersionUptoDate = $env:COMPUTERNAME + " Up-To-Date"
}
else{
    #Version not up-to-date.
    $VersionUptoDate = $env:COMPUTERNAME + " Not Up-To-Date"
}
