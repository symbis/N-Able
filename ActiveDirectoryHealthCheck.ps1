<#
.SYNOPSIS 
Check Health of Domain Controller
.DESCRIPTION
Check Health of Domain Controller with nltest, Windows Eventvwr, DCDiag, W32TM
.NOTES
Created by Barend vd Dussen
Date: 10-03-2023
Outputs: $script:DCDiagResults - $script:nltest - $script:LDAPSecure, [int]$script:DCDIAGFaults, [int]$script:w32TMPeers,  $script:ReplicationResult, $script:GPOName
Version: 1..0
Release Notes
V0.1: Initial Setup
V.02: Bugs wegwerken
V0.3: div. bugs wegwerken
V1.0: 1e versie AD health check

#>

Function checkDNS {
    #check DNS with nltest
	$script:nltestCheck = nltest /dsquerydns
    if($script:nltestCheck -like "There was no failure in the last update for all DC-specific DNS records")
    {
        return $script:nltest = "Okay"
    }
    else {
        return $script:nltest = "Er is iets niet goed met Domain Related DNS. Voer 'nltest /dsquerydns' uit voor meer info."
    }
}

Function checkLDAPSecure{
    #Check LDAP Secure events
    try { 
         $script:LDAPSecure = Get-WinEvent -FilterHashtable @{
            LogName = 'Security' 
                ID = 2889
            } -ErrorAction Stop
    }
    catch [Exception] {
        if ($_.Exception -match "No events were found that match the specified selection criteria") {
        return $script:LDAPSecure = "Okay"
        }
    }
}

Function Test-AdhcDCDiag {    
    [cmdletbinding()]
    param(
        # Name of the DC
        [parameter(ValueFromPipeline)]
        [string]$ComputerName,

        # What DCDiag tests would you like to run?
        [ValidateSet(
            "All",
            "Advertising",
            "DNS",
            "NCSecDesc",
            "KccEvent",
            "Services",
            "NetLogons",
            "CrossRefValidation",
            "CutoffServers",
            "CheckSecurityError",
            "Intersite",
            "CheckSDRefDom",
            "Connectivity",
            "SysVolCheck",
            "Replications",
            "ObjectsReplicated",
            "DcPromo",
            "RidManager",
            "Topology",
            "MachineAccount",
            "LocatorCheck",
            "OutboundSecureChannels",
            "RegisterInDNS",
            "VerifyEnterpriseReferences",
            "KnowsOfRoleHolders",
            "VerifyReplicas",
            "VerifyReferences"
        )]
        [string[]]$Tests = "All",

        # Excluded tests
        [ValidateSet(
            "Advertising",
            "DNS",
            "NCSecDesc",
            "KccEvent",
            "Services",
            "NetLogons",
            "CrossRefValidation",
            "CutoffServers",
            "CheckSecurityError",
            "Intersite",
            "CheckSDRefDom",
            "Connectivity",
            "SysVolCheck",
            "Replications",
            "ObjectsReplicated",
            "DcPromo",
            "RidManager",
            "Topology",
            "MachineAccount",
            "LocatorCheck",
            "OutboundSecureChannels",
            "RegisterInDNS",
            "VerifyEnterpriseReferences",
            "KnowsOfRoleHolders",
            "VerifyReplicas",
            "VerifyReferences"
        )]
        [string[]]$ExcludedTests
        
    )
    Begin {
        $DCDiagTests = @{
            Advertising = @{}
            CheckSDRefDom = @{}
            Connectivity = @{}
            CrossRefValidation = @{}
            CutoffServers = @{}
            DcPromo = @{
	            ExtraArgs = @(
                    "/ReplicaDC",
                    "/DnsDomain:$((Get-ADDomain).DNSRoot)",
                    "/ForestRoot:$((Get-ADDomain).Forest)"
                )
            }
            DNS = @{}
            SysVolCheck = @{}
            LocatorCheck = @{}
            Intersite = @{}
            KccEvent = @{}
            KnowsOfRoleHolders = @{}
            MachineAccount = @{}
            NCSecDesc = @{}
            NetLogons = @{}
            ObjectsReplicated = @{}
            OutboundSecureChannels = @{}
            RegisterInDNS = @{
	            ExtraArgs = "/DnsDomain:$((Get-ADDomain).DNSRoot)"
            }
            Replications = @{}
            RidManager = @{}
            Services = @{}
            Topology = @{}
            VerifyEnterpriseReferences = @{}
            VerifyReferences = @{}
            VerifyReplicas = @{}
        }

        $TestsToRun = $DCDiagTests.Keys | Where-Object {$_ -notin $ExcludedTests}

        If($Tests -ne 'All'){
            $TestsToRun = $Tests
        }
        
        if(($Tests | Measure-Object).Count -gt 1 -and $Tests -contains "All"){
            Write-Error "Invalid Tests parameter value: You can't use 'All' with other tests." -ErrorAction Stop
        }

        Write-Verbose "Executing tests: $($DCDiagTests.Keys -join ", ")"
    }
    Process {
        if(![string]::IsNullOrEmpty($ComputerName)) {
             $ServerArg = "/s:$ComputerName"
        }
        else {
            $ComputerName = $env:COMPUTERNAME
            $ServerArg = "/s:$env:COMPUTERNAME"
        }
        [string]$script:DCDiagResults = 0
        $TestsToRun | Foreach {

            $TestName = $_
            $ExtraArgs = $DCDiagTests[$_].ExtraArgs

            
            if($_ -in @("DcPromo", "RegisterInDNS")){
                if($env:COMPUTERNAME -ne $ComputerName){

                    Write-Verbose "Test cannot be performed remote, invoking dcdiag"
                    $Output = Invoke-Command -ComputerName $ComputerName -ArgumentList @($TestName,$ExtraArgs) -ScriptBlock {
                        $TestName = $args[0]
                        $ExtraArgs = $args[1]
                        dcdiag /test:$TestName $ExtraArgs
                    }
                }
                else {
                    $Output = dcdiag /test:$TestName $ExtraArgs
                }
            }
            else {
                $Output = dcdiag /test:$TestName $ExtraArgs $ServerArg    
            }
            

            $Fails = ($Output | Select-String -AllMatches -Pattern "fail" | Measure-Object).Count
            $Passes = ($Output | Select-String -AllMatches -Pattern "passed" | Measure-Object).Count 
            $Pass = ($Fails -eq 0 -and $Passes -gt 0)
            if($Pass -ne $true){
                Write-host "$_"
                $script:DCDIAGFaults += 1
                if($_ -ne "0"){[string]$script:DCDiagResults += $_ + ", "}
            }  
        }
        Write-Host $script:DCDIAGFaults
        if($script:DCDIAGFaults -eq 0 -or $script:DCDIAGFaults -eq $null)
        {
        [string]$script:DCDiagResults = "Healthy"
        }
        else
        {
           [string]$script:DCDiagResults = [string]$script:DCDiagResults.Remove(0,1)
        }

    }
    End {

    }
 
}

Function checkW32TM{
    #Check W32TM peers
    [string]$script:W32TM = w32tm /query /peers | Select-String -Pattern "#Peers"
    if($script:W32TM)
    {
        return [int]$script:w32TMPeers = $script:w32TM.replace('#Peers: ', '')
    }
    else
    {
         return [int]$script:w32TMPeers = 0
    }
}

Function checkReplicationState{
    #basic check of replication State of AD.
    if((Get-ADReplicationPartnerMetadata -Target $env:computername).LastReplicationResult -eq 0 -or (Get-ADReplicationPartnerMetadata -Target $env:computername).LastReplicationResult -eq $null)
    {
       return [string]$script:ReplicationResult =  "Okay"
    }
    Else 
    {
        return [string]$script:ReplicationResult =  "Er is iets niet goed met AD Replicatie"
    }
    
}

Function checkADGPOReplication {    
    #Get GPO replication State
    [CmdletBinding()]
    param(
    )
    BEGIN {
        TRY {
            if (-not (Get-Module -Name ActiveDirectory)) { Import-Module -Name ActiveDirectory -ErrorAction Stop -ErrorVariable ErrorBeginIpmoAD }
            if (-not (Get-Module -Name GroupPolicy)) { Import-Module -Name GroupPolicy -ErrorAction Stop -ErrorVariable ErrorBeginIpmoGP }
            if(-not (Get-WindowsFeature -Name "GPMC").installed){Install-WindowsFeature GPMC}
            #clear-variable -scope script -Name GPOName
        }
        CATCH {
            Write-Warning -Message "[BEGIN] Something wrong happened"
            IF ($ErrorBeginIpmoAD) { Write-Warning -Message "[BEGIN] Error while Importing the module Active Directory" }
            IF ($ErrorBeginIpmoGP) { Write-Warning -Message "[BEGIN] Error while Importing the module Group Policy" }
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
    PROCESS {
        FOREACH ($DomainController in ((Get-ADDomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetDC -filter *).hostname)) {
            TRY {
                $GPOList = Get-GPO -All -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPOAll
                foreach ($GPO in $GPOList) {
                    if($GPO.User.DSVersion -ne $GPO.User.SysvolVersion -or $GPO.Computer.DSVersion -ne $GPO.Computer.SysvolVersion)
                    {
                        [string]$script:GPOName += $GPO.DisplayName
                    }
                    # [pscustomobject][ordered] @{
                    #     GroupPolicyName       = $GPO.DisplayName
                    #     DomainController      = $DomainController
                    #     UserVersion           = $GPO.User.DSVersion
                    #     UserSysVolVersion     = $GPO.User.SysvolVersion
                    #     ComputerVersion       = $GPO.Computer.DSVersion
                    #     ComputerSysVolVersion = $GPO.Computer.SysvolVersion
                    # }
                }
                if([string]$script:GPOName -eq ""){[string]$script:GPOName = "Okay"}
                return $script:GPOName
            }           
            CATCH {
            Write-Warning -Message "[PROCESS] Something wrong happened"
            IF ($ErrorProcessGetDC) { Write-Warning -Message "[PROCESS] Error while running retrieving Domain Controllers with Get-ADDomainController" }
            IF ($ErrorProcessGetGPO) { Write-Warning -Message "[PROCESS] Error while running Get-GPO" }
            IF ($ErrorProcessGetGPOAll) { Write-Warning -Message "[PROCESS] Error while running Get-GPO -All" }
            $PSCmdlet.ThrowTerminatingError($_)
            }
        }
        
    }
}

checkDNS
checkLDAPSecure
test-AdhcDCDiag
checkW32TM
checkReplicationState
checkADGPOReplication