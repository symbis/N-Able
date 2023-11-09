clear
#######################################################################################
# Name: RDS_Used_Licenses.ps1
# Version: 1.1
# Author: AenC ICT Solutions
#######################################################################################

# Settings #

$emailFrom = "b.vanderdussen@aenc.nl"
$emailTo = "b.vanderdussen@aenc.nl"
$Subject = "Bijlage Licentie Rapportage"
$body = "Zie bijlage voor het rapport"
$PSEmailServer = "smtpout-eu.mtaroutes.com"
$datum = get-date


# Voorbereiding & argumenten behandelen#
if ($args.count -ge 1){
$emailfrom = $args[0]
$emailto = $args[1]
$PSEmailServer = $args[2]
$loc = $args[3]
}
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
    $username
    $adobject = get-aduser -Identity $user -properties lastlogon
    $rawtime = $adobject.lastlogon
    $time = [DateTime]::FromFileTime($rawtime)
    $verschil = $datum - $time
        if ($verschil.days -lt 30) {
        $y = $r.ExpirationDate.substring(0,4)
        $m = $r.ExpirationDate.substring(4,2)
        $d = $r.ExpirationDate.substring(6,2)
        $y2 = $r.issueDate.substring(0,4)
        $m2 = $r.issueDate.substring(4,2)
        $d2 = $r.issueDate.substring(6,2)
        $ly = $time.Year
        $lm = $time.Month
        $ld = $time.Day
        #write-host $user","("{0:dd-MM-yyyy}" -f $time)","$d-$m-$y","$d2-$m2-$y2 
        add-content $file $user","$ld-$lm-$ly","$d-$m-$y","$d2-$m2-$y2 
        }

    }

}

# Send Email #
$UserSecurestring = "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000032f43321b517414f8729f0b5643f9bf00000000002000000000010660000000100002000000054b23e667dddbff748d09097e13e82bb24afa61bf4d434df5b0a1990f9a51c9c000000000e8000000002000020000000682ef925d2a4fabf5f2602d7f50ba928d15395ebe0a1cb0460a9e058f5f15d383000000058d14ad83e575df6bb68a170af414a537c2a6b0a858f6bb45e04bd335d650bfa07060b7a65992dec58b1b6b9f5c5969a40000000b6fc6e614eabefa53fc2e4ea6d680ba60bd1c11b4ac674008658c60a7fb243e5bbb3676a32288d2cfed15d65262fb6d00cb37acc023230699228d241483c8ca0
"
$PasswordSecureString = "01000000d08c9ddf0115d1118c7a00c04fc297eb0100000032f43321b517414f8729f0b5643f9bf000000000020000000000106600000001000020000000772aba513a3b806f7309d313a77ae8e503675aa5a18b4b703783370dbba58547000000000e8000000002000020000000befc87c5523f66facbc979be8b6af1400d946e99cec684405395a66ddee06eba10000000c183c6aef563ad82ad08c4898d1decc54000000099b17f3d067f519822a94f82e7132ef0acab2bda9aea51113605b60022753c27b2e6cf599724d1b8d87241a08c8cb25ae83ffafbb2072e2412c88efeb70a64b1"
$cred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, ($PasswordSecureString | ConvertTo-SecureString)
Send-MailMessage -From 'support@aenc.nl' -to 'b.vanderdussen@aenc.nl' -subject 'RDS Licenties' -Body 'testtest' -SmtpServer 'smtpout-eu.mtaroutes.com' -Credential $cred

send-mailmessage -From $emailFrom -To $emailto -Subject $Subject -Body $body -Attachments $file
