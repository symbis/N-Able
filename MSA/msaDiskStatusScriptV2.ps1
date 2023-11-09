################################################
#
# Vaste settings
#
################################################
$cmd = "Show Disks"
$xmlfile = 'output.xml'
$xmlfolder = "" #leave empty, randomly generated
$diskarray = @()
$faultydiskarray = @()
$totaldisks = 0
$totalfaultydisks = 0
$faultydisklist = "Disk Location: " 

write-host "Versie 1.21"

$MSACLI = "C:\aenc\msa"
################################################
#
# N-Able Settings - Aanpassen in AMP
#
################################################
$username = "manage"
$password =  "D3H@@n123"
$ip =  "192.168.1.201"
$msaclifolder = $MSACLI


################################################
#
# create random string for temp file
# in order to prevent overwriting same file if n-central scans run simultaneous
#
################################################
$set    = "abcdefghijklmnopqrstuvwxyz0123456789".ToCharArray()
$result = ""
for ($x = 0; $x -lt 8; $x++) {
    $xmlfolder += $set | Get-Random
}
New-Item -ItemType Directory -Path $msaclifolder -Name $xmlfolder
sleep -seconds 10
New-Item -ItemType File -Path $xmlfolder -Name $xmlfile
sleep -seconds 10
write-host "Using Folder $xmlfolder"

cd $msaclifolder"\"$xmlfolder
try{
$show_disk = echo y | &($msaclifolder + "\plink.exe") -pw $password $username@$ip $cmd
add-content $xmlfile $show_disk
}
catch [exception]
{
    write-host "probleem met ophalen van gegeven! Controleer de .EXE en credentials"
}
if (!(Test-Path -path $msaclifolder\$xmlfolder)) 
{
write-host "Map lijkt niet te bestaan! dit is een probleem."
}
else
{
 cd $msaclifolder\$xmlfolder
}
(gc ($xmlFolder + $xmlfile) | select -Skip 1 | select -skiplast 1) | sc $xmlfile
[xml]$xmldata = get-content "$msaclifolder\$xmlfolder\$xmlfile"
    $data = $xmldata.RESPONSE.OBJECT 
    foreach ($item in $data)
                                                                                                                                                                                                                                                                    {
    if ($item.name -eq "drive") {
        $id = $item.oid
        $totaldisks++
        $xmlproperties = $xmldata.SelectNodes("/RESPONSE/OBJECT[$id]/PROPERTY")
        write-host "-------------------------------------------------"
        write-host "New Disk Found: "
        write-host "-------------------------------------------------"
        $diskinfo = new-object psobject	
        foreach ($property in $xmlproperties){
        
            if ($property.name -eq "status"){
                write-host "Disk status: " $property.'#text'
            }
            if ($property.name -eq "location"){
                $diskloc = $property.'#text'
                write-host "Disk Location: " $property.'#text'
                $diskinfo | Add-Member -membertype noteproperty -name "Disk Location" -Value $property.'#text'
            }
            if ($property.name -eq "serial-number"){
                write-host "Disk serial-number: " $property.'#text'
                $diskinfo | Add-Member -membertype noteproperty -name "Disk Serial Number" -Value $property.'#text'
            }
            if ($property.name -eq "model"){
                write-host "Disk model: " $property.'#text'
                $diskinfo | Add-Member -membertype noteproperty -name "Disk Model" -Value $property.'#text'
            }
            if ($property.name -eq "status"){
                write-host "status: " $property.'#text'

            }
            if ($property.name -eq "health"){
                write-host "health: " $property.'#text'
                $diskinfo | Add-Member -membertype noteproperty -name "Disk Health" -Value $property.'#text'
            }
            if ($property.name -eq "health-numeric"){
                $num = $property.'#text'
                write-host "health-numeric: " $property.'#text'
                if ($num -ne 0)
                    {
                        $totalfaultydisks++
                    }
            }
            if ($property.name -eq "health-reason"){
                $health = $property.'#text'
                if (!$health) { $health = "n/a - Disk OK"}
                write-host "Disk Health: " $health
                $diskinfo | Add-Member -membertype noteproperty -name "Disk Health Reason" -Value $health
            }
            if ($property.name -eq "vendor"){
                write-host "vendor: " $property.'#text'
                $diskinfo | Add-Member -membertype noteproperty -name "Disk Vendor" -Value $property.'#text'
            }
            if ($property.name -eq "storage-pool-name"){
                write-host "storage-pool-name: " $property.'#text'
                $diskinfo | Add-Member -membertype noteproperty -name "Storage Pool" -Value $property.'#text'
            }
        }
        $diskarray += $diskinfo
        if ($num -ne 0)
            {
                $faultydiskarray += $diskinfo
                $faultydisklist = $faultydisklist + $diskloc + ", "
            }
    }
    }

    #$diskarray | Out-GridView -Title "Disk Overview"
write $diskarray | out-gridview -Title "MSA Storageworks Disk overview"
write "Total Disks: " $totaldisks
write "Total Disks Faulty: "$totalfaultydisks
write $faultydiskarray | ft
write $faultydisklist

$ARRDISKS = $diskarray
$ARRFDISKS = $faultydisklist
$TOTDISK = $totaldisks
$TOTFDISKS = $totalfaultydisks


<#
Klaar met het script. nu onze zooi opruimen.
we ruimen gelijk alle folders op, want we hebben geen sub-folders nodig.
#>
cd $msaclifolder
Remove-Item -Path $msaclifolder\$xmlfolder -Force -Recurse
if (!(Test-Path -path $msaclifolder\$xmlfolder)) 
{
    write-host "Map is verwijderd!"
}
else
{
    write-host "De map is er nog! nogmaals verwijderen"
    sleep -Seconds 60
    cd $msaclifolder
    Remove-Item -Path $msaclifolder\$xmlfolder -Force -Recurse
}

