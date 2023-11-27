<# 
.SYNOPSIS  
Check Veeam Version information
.DESCRIPTION 
Check Veeam Version information
.NOTES 
Created by Barend vd Dussen 
Date: 14-11-2023
Inputs: $LatestAvailableVersion[string]
Outputs: $InstalledVersion[string], $VersionUptoDate[int]
Version: 1.0 
Release Notes 
V1.0: Initial Setup 
#> 


#Get Veeam Version Info
$InstallPath = Get-ItemProperty -Path "HKLM:\Software\Veeam\Veeam Backup and Replication\" | Select -ExpandProperty CorePath
Add-Type -LiteralPath "$InstallPath\Veeam.Backup.Configuration.dll" 
$ProductData = [Veeam.Backup.Configuration.BackupProduct]::Create()
$InstalledVersion = $ProductData.ProductVersion.ToString()
if ($ProductData.MarketName -ne "") {$InstalledVersion += " $($ProductData.MarketName)"}

#compare Version with latest available version
if($InstalledVersion -eq $LatestAvailableVersion){
    #Veeam up to date
    $VersionUptoDate = 1
}
else{
    #Veeam Version out-of-date
    $VersionUptoDate = 0
}