$username = "manage"
$password = "D3H@@n123"
$IPaddress = "192.168.1.201"
$cmd = "Show Disks"
$xmlfile = 'msaoutput.xml'
$xmlFolder = "C:\aenc\msa\"
$client = new-object System.Net.WebClient

#check and create msa folder
$testpath = Test-Path $xmlFolder
if (-Not $testpath) {mkdir $xmlFolder}
cd $xmlFolder

#check and download plink.exe
$testpath = Test-Path ($xmlFolder + "plink.exe")
if (-Not $testpath) {$client.DownloadFile("https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe","C:\aenc\msa\plink.exe")}

#check and create xml file
$testpath = Test-Path ($xmlFolder + $xmlfile)
if (-Not $testpath) {New-Item -ItemType File -Path $xmlFolder -Name $xmlfile}

#execute msa command
$show_disk = echo y | .\plink.exe -ssh $IPaddress -l $username -pw $password $cmd
add-content $xmlfile $show_disk
[xml]$xmldata = get-content ($xmlFolder + $xmlfile)
    $data = $xmldata.RESPONSE.OBJECT 
    foreach ($item in $data){
        if ($item.name -eq "drive")
        {
            echo "hello world"
        }
    }

