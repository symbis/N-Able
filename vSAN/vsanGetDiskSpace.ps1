#Script to read XML Vsan Health
[xml]$XmlDocument = Get-Content -Path "C:\aenc\vsan\vsan.xml"
$diskSpaceHealth = $XmlDocument.DocumentElement.FirstChild.DiskSpaceHealth
$UsedDiskCapacity = $XmlDocument.DocumentElement.FirstChild.UsedDiskCapacity
$UsedDiskpercCapacity = $XmlDocument.DocumentElement.FirstChild.UsedDiskpercCapacity



