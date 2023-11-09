#######################################################################################
# Name: RDS_Used_Licenses.ps1
# Version: 2.0
# Author: AenC ICT Solutions
#######################################################################################

# Settings #

$emailFrom = "Rapportage AENC<support@aenc.nl>"
$emailTo = $recpemailaddress
$body = "Zie bijlage voor het rapport"
$PSEmailServer = "smtpout-eu.mtaroutes.com"
$Subject = "RDS Gebruikers Rapportage $env:computername"
$datum = get-date


# Voorbereiding & argumenten behandelen#

$loc = "C:\aenc\RDS_Users_" + $env:COMPUTERNAME +  ".csv"
$file = new-Item -type file $loc -force
add-content $file "Gebruiker, Laatst ingelogd, RDS Licentie verloopt op, RDS Licentie uitgegeven"

# Licenties uitlezen #

$a = get-wmiobject -Class Win32_TSIssuedLicense

Foreach ($r in $a)
{
$split = $r.sIssuedToUser.split("\")
$user = $split[1]
    if (($user -notlike "administrator") -and ($user -notlike "testaenc2") -and ($user -notlike "TESTaenc")){
        try
        {
            $username
            $adobject = get-aduser -Identity $user -properties lastlogon
            $rawtime = $adobject.lastlogon
            $time = [DateTime]::FromFileTime($rawtime)
            $verschil = $datum - $time
            if ($verschil.days -lt 30) 
            {
                $y = $r.ExpirationDate.substring(0,4)
                $m = $r.ExpirationDate.substring(4,2)
                $d = $r.ExpirationDate.substring(6,2)
                $y2 = $r.issueDate.substring(0,4)
                $m2 = $r.issueDate.substring(4,2)
                $d2 = $r.issueDate.substring(6,2)
                $ly = $time.Year
                $lm = $time.Month
                $ld = $time.Day
                add-content $file $user","$ld-$lm-$ly","$d-$m-$y","$d2-$m2-$y2 
            }
        }
        catch
        {
            Write-Host "Gebruiker " + $user + " Niet gevonden!"
        }
    }
}

# Send Email #
$SecurePassword = $AuthPassword | ConvertTo-SecureString -AsPlainText -Force
$UserName = "rapportage@aenc.nl"
$cred = New-Object System.Management.Automation.PSCredential ` -ArgumentList $UserName, $SecurePassword
Send-MailMessage -From $emailFrom -to $emailTo -subject $Subject -Body $body -Attachments $file -SmtpServer $PSEmailServer -Credential $cred -Port 587 -UseSsl
