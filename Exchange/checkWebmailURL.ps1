if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$URL = Get-OwaVirtualDirectory -Server $env:computername | select *IntenalURL*
$psOWAURL = $URL.InternalUrl.ToString()
$psStatusCode = (Invoke-WebRequest -UseBasicParsing -Uri $psOWAURL).statuscode
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
$OWAURLCert = [System.Net.ServicePointManager]::FindServicePoint($psOWAURL)
$expDate = $OWAURLCert.Certificate.GetExpirationDateString()
$certExpDate = [System.DateTime]::Parse($expDate)
[int]$PScertExpiresIn = ($certExpDate - $(get-date)).Days
if($psStatusCode -eq 200)
{
    #website is running
    $psStatus = "OK"
}
else 
{
    #Website is niet running
    $psStatus = "Webmail URL is down"
}
