<#
script voor het installeren van de N-Able agent op een image
Auteur: Barend van der Dussen
Update datum: 27-1-2021
Versie 1.0

Vereisten:
agent.ini moet in zelfde location staan als script
agent.ini moet exact deze naam zijn, anders werkt het niet.
WindowsAgentSetup.exe moet in zelfde locatie staan als script
WindowsAgentSetup.exe moet exact deze naam zijn, anders werkt het niet.
#>

$registrationToken = ""
$customerID = ""
$customerName = ""
$agentLocation = $PSScriptRoot + "\WindowsAgentSetup.exe" 
$iniLocation = $PSScriptRoot + "\agent.ini"
$logfilename = 'agentinstallationlog.txt'
$logfileLocation = $PSScriptRoot
$Logfile = $logfileLocation + '\' + $logfilename
$logOutput = ''


Function LogWrite ([String]$logOutput) {
    if (!(Test-Path $Logfile -PathType Leaf)) {
        New-Item -Path $logfileLocation -Name $logfilename -ItemType "File"
    }    
    $currentDate = (Get-Date -UFormat "%d-%m-%Y")
    $currentTime = (Get-Date -UFormat "%T")
    $logOutput = $logOutput -join (" ") 
    Add-Content -Path $Logfile -Value "[$currentDate $currentTime] $logOutput"
}

if(Test-Path $iniLocation)
{
    #ini file is aanwezig
    $iniContent = Get-Content $iniLocation | Select -Skip 0 | ConvertFrom-StringData
    $registrationToken = $iniContent.registrationToken
    $customerID = $iniContent.customerID
    $customerName = $iniContent.customerName
    $agentFileExist = Test-Path $agentLocation
    $hostname = hostname
    #alle benodigde informatie verzameld
    if($registrationToken -and $customerID -and $customerName -and $agentFileExist -eq $true) 
    {
        #Alle benodigde informatie en bestanden zijn aanwezig
        Set-Location $PSScriptRoot
        .\WindowsAgentSetup.exe /s /v" /qn CUSTOMERID=$customerID CUSTOMERNAME=$customerName REGISTRATION_TOKEN=$registrationToken SERVERPROTOCOL=HTTPS SERVERADDRESS=login.zorgvoorict.nl SERVERPORT=443 "
        $logOutput = '{0} : Alle benodigde informatie is er, agent wordt geïnstalleerd, wanneer dit faalt, controleer de WindowsAgentSetup.exe of controleer dat het ini bestand de juiste informatie bevat.' -f $hostname
        LogWrite -logOutput $logOutput
    }
    else 
    {
        #agent kan niet worden geïnstalleerd door het missen van gegevens
        $logOutput = '{0} : Ik mis gegevens! controleer of het agent.ini bestand aanwezig is en of volledig is. Controleer ook even of de WindowsAgentSetup.exe aanwezig is. Let op! exact deze namen hanteren anders ga ik niet werken.' -f $hostname
        LogWrite -logOutput $logOutput
    }
}


