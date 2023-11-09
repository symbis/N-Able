#[Version]$MyDeviceVersion = $current_version
[Version]$MyDeviceVersion = "6.2.6" 
$MyDevice = "FortiOS"

$MyDeviceVersion_onlyNumbers = $MyDeviceVersion -replace "[^0-9]" , ''
$MyDeviceVersion_FirstNumber = MyDeviceVersion_onlyNumbers.substring(0,1)
#$MyDeviceVersion_middelNumber = 
#$MyDeviceVersion_LastNumber = 

[xml]$rssData = Invoke-WebRequest "http://pub.kb.fortinet.com/rss/firmware.xml"

$rssData.rss.channel.item | ForEach-Object {
    [string]$TitleData = $_.title
    $a = $TitleData.Split(' ')
    $Title = $a[0]
    [Version]$Version = $a[1]
    if($MyDevice -match $Title -and $MyDeviceVersion -ne $Version){
        "Update for $($Title.ToString()) v$($MyDeviceVersion) -> $($Version)"
    }
}