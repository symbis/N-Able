 <#
.SYNOPSIS 
Check change date of GPO
.DESCRIPTION
Check change date of GPO
.NOTES
Created by Barend vd Dussen
Date: 19-10-2023
Inputs: $gponame, $gpoLastAllowedChangeDate
Outputs: $lastChangeDate, $gponame, $gpoChanged
Version: 1.0
Release Notes
V1.0: Initial Setup
#>
$gponame = "CA Root certificate trust"
$gpoLastAllowedChangeDate = get-date "21-11-2022"

if($gponame){
    try{
        $GPO = get-GPO -name $gponame
        $lastChangeDate = ($gpo.ModificationTime).ToString("dd/MM/yyyy")
        if((get-date $lastChangeDate) -gt (get-date $gpoLastAllowedChangeDate)){
            #GPO has changed after the last allowed date.
            $gpoChanged = 1
        }
        else{
            #GPO hasn't changed
            $gpoChanged =0
        }
    }
    catch{
        #error occured
        Write-Host $error[0]
    }        
}
else{
    Write-Host "No GPO name provided"
} 
