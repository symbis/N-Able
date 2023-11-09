#Script to read XML Vsan Health
[xml]$XmlDocument = Get-Content -Path "C:\aenc\vsan\vsan.xml"
$NetworkHealth = $XmlDocument.DocumentElement.FirstChild.Network
