#Script input / instellingen
$providerReq = Get-PackageProvider
$ReqVersion = get-packageprovider | ? {$_.Name -contains "Nuget"}
$moduleReq = get-module
$vCenter_server = $vCenter   #vul hier de target vcenter in
$username = $User  #account met rechten op vcenter (mag ook read-only zijn)
$password = $Pass #Password voor bovenstaande account. ToDo = Ombouwen naar encrypted file?
$file = "C:\aenc\vSan\vSan_Health_$vCenter.txt"


Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -Confirm:$false

#Maak een logfile aan
New-Item -ItemType File -path "C:\aenc\vSan\" -Name "vSan_Health_$vcenter.txt" -Force



#Controleer op aanwezigheid benodigde VMwareCLI Modules en juiste versie
if(($moduleReq.Name) -contains "VMware.VimAutomation.Core"){write-host "module aanwezig"}
Else{

    #Controleer op aanwezigheid Package-Provider om VMware CLI te kunnen downloaden en gebruiken
    if((($providerReq.Name) -contains "Nuget") -and ((($ReqVersion.version) -ge "2.8.5.208"))){
        }
    Else{
         if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        
    }     

    #Installeer VMwareCLI Modules
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

        Install-Module -Name VMware.PowerCLI
        
}

#Connect-VIServer -Server $vCenter_server -User $username -Password $password
#Probeer verbinding te maken met de opgegeven Vcenter na eerst de eventueel openstaande CLIsessies vanuit dit script te sluiten
$Stoploop = $false
[int]$Retrycount = "0"
 
do {
 try {
 Connect-VIServer -Server $vCenter_server -User $username -Password $password 
 Start-Sleep -Seconds 10
 Write-Host "Job completed"
 $Stoploop = $true
 }
 catch {
 if ($Retrycount -gt 3){
 Write-Host "Could not send Information after 3 retrys."
 $Stoploop = $true
 }
 else {
 Write-Host "Kan geen verbinding maken. Opnieuw proberen in 30 seconds..."
 Start-Sleep -Seconds 30
 $Retrycount = $Retrycount + 1
 }
 }
}
While ($Stoploop -eq $false)

#Benodigde functies inladen in script sessie
Function Get-VSANHealthSummary
{
	
<#
.SYNOPSIS
	Fetch vSAN Cluster Health Status.
.DESCRIPTION
    This function performs a cluster wide health check across all types of Health Checks.
.PARAMETER VsanCluster
    Specifies a vSAN Cluster object(s), returned by Get-Cluster cmdlet.
.PARAMETER FetchFromCache
	If specified the results are returned from cache directly instead of running the full health check.
.PARAMETER SummaryLevel
	Specifies Health Check sets. If Strict level selected, the Best Practices Health Checks will be taken.
.EXAMPLE
	PS C:\> Get-Cluster VSAN-Cluster |Get-VSANHealthSummary Strict -Verbose
.EXAMPLE
    PS C:\> Get-Cluster |Get-VSANHealthSummary -FetchFromCache |ft -Property cluster,*health -au
.NOTES
	Author      :: Roman Gelman @rgelman75
	Requirement :: PowerCLI 6.5.1, VSAN 6.6
	Version 1.0 :: 27-Apr-2017 :: [Release] :: Publicly available
.LINK
	https://ps1code.com/2017/05/08/vsan-health-check
#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[Alias("Cluster")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$VsanCluster
		 ,
		[Parameter(Mandatory = $false)]
		[Alias("Cache")]
		[switch]$FetchFromCache
		 ,
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateSet("Default", "Strict")]
		[Alias("Level")]
		[string]$SummaryLevel = 'Default'
	)
	
	Begin
	{
		$vchs = Get-VsanView -Id "VsanVcClusterHealthSystem-vsan-cluster-health-system" -Verbose:$false
		$fromCache = if ($FetchFromCache) { $true } else { $false }
		$perspective = if ($SummaryLevel -eq 'Default') { 'defaultView' } else { 'deployAssist' }
		$FormatDate = "dd'/'MM'/'yyyy HH':'mm':'ss"
	}
	Process
	{
		if ($VsanCluster.VsanEnabled)
		{
			$result = $vchs.VsanQueryVcClusterHealthSummary($VsanCluster.Id, 2, $null, $true, $null, $fromCache, $perspective)
			
			$NetworkHealth = if ($result.NetworkHealth.IssueFound) {'Yellow'} else {'Green'}
			
			$summary = [pscustomobject]@{
				Cluster = $VsanCluster.Name
				OverallHealth = (Get-Culture).TextInfo.ToTitleCase($result.OverallHealth)
				OverallHealthDescr = $result.OverallHealthDescription
				Timestamp = (Get-Date $result.Timestamp).ToLocalTime().ToString($FormatDate)
				VMHealth = (Get-Culture).TextInfo.ToTitleCase($result.VmHealth.OverallHealthState)
				NetworkHealth = $NetworkHealth
				DiskHealth = (Get-Culture).TextInfo.ToTitleCase($result.PhysicalDisksHealth.OverallHealth)
				DiskSpaceHealth = (Get-Culture).TextInfo.ToTitleCase($result.LimitHealth.DiskFreeSpaceHealth)
				HclDbHealth = (Get-Culture).TextInfo.ToTitleCase($result.HclInfo.HclDbAgeHealth)
				HclDbTimestamp = (Get-Date $result.HclInfo.HclDbLastUpdate).ToLocalTime().ToString($FormatDate)
			}
			
			if ($null -ne $result.ClusterStatus.UntrackedHosts) { $summary | Add-Member -MemberType NoteProperty -Name VMHostUntracked -Value $result.ClusterStatus.UntrackedHosts }
			if ($null -ne $result.PhysicalDisksHealth.ComponentsWithIssues) { $summary | Add-Member -MemberType NoteProperty -Name DiskProblem -Value $result.PhysicalDisksHealth.ComponentsWithIssues }
			$summary
		}
		else
		{
			Write-Verbose "The [$($VsanCluster.Name)] cluster is not VSAN Enabled"
		}
	}
	End { }
	
} #EndFunction Get-VSANHealthSummary

Function Invoke-VSANHealthCheck
{
	
<#
.SYNOPSIS
	Run vSAN Cluster Health Test.
.DESCRIPTION
    This function performs a cluster wide health check across all types of Health Checks.
.PARAMETER VsanCluster
    Specifies a vSAN Cluster object(s), returned by Get-Cluster cmdlet.
.PARAMETER Level
	Specifies Health Check tests level. Available levels are Group or Test level.
.PARAMETER HideGreen
	If specified, Green or Skipped Health Checks will be removed from the resultant report.
.EXAMPLE
	PS C:\> Get-Cluster |Invoke-VSANHealthCheck -Verbose |sort Health
.EXAMPLE
    PS C:\> Get-Cluster |Invoke-VSANHealthCheck -Level Test |select * -exclude descr* |sort TestGroup,Test |ft -au
.EXAMPLE
    PS C:\> Get-Cluster VSAN-Cluster |Invoke-VSANHealthCheck Test -HideGreen |sort Health
.NOTES
	Author      :: Roman Gelman @rgelman75
	Requirement :: PowerCLI 6.5.1, VSAN 6.6
	Version 1.0 :: 30-Apr-2017 :: [Release] :: Publicly available
.LINK
	https://ps1code.com/2017/05/08/vsan-health-check
#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory, ValueFromPipeline)]
		[Alias("Cluster")]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]$VsanCluster
		 ,
		[Parameter(Mandatory = $false, Position = 0)]
		[ValidateSet("Group", "Test")]
		[string]$Level = 'Group'
		 ,
		[Parameter(Mandatory = $false)]
		[switch]$HideGreen
	)
	
	Begin
	{
		$vchs = Get-VsanView -Id "VsanVcClusterHealthSystem-vsan-cluster-health-system" -Verbose:$false
	}
	Process
	{
		if ($VsanCluster.VsanEnabled)
		{
			$result = $vchs.VsanQueryVcClusterHealthSummary($VsanCluster.Id, 2, $null, $true, $null, $false, 'defaultView')
			
			if ($Level -eq 'Group') {
				foreach ($Group in $result.Groups) {
					$obj = [pscustomobject] @{
						Cluster = $VsanCluster.Name
						TestGroup = $Group.GroupName
						Health = (Get-Culture).TextInfo.ToTitleCase($Group.GroupHealth)
					}
					if ($PSBoundParameters.ContainsKey('HideGreen'))
					{
						if ('green', 'skipped' -notcontains $obj.Health) { $obj }
					}
					else { $obj }
				}
			}
			else
			{
				foreach ($Group in $result.Groups)
				{
					foreach ($Test in $Group.GroupTests)
					{
						$obj = [pscustomobject] @{
							Cluster = $VsanCluster.Name
							TestGroup = $Group.GroupName
							Test = $Test.TestName
							Description = $Test.TestShortDescription
							Health = (Get-Culture).TextInfo.ToTitleCase($Test.TestHealth)
						}
						if ($PSBoundParameters.ContainsKey('HideGreen'))
						{
							if ('green', 'skipped' -notcontains $obj.Health) { $obj }
						}
						else { $obj }
					}
				}
			}
		}
		else
		{
			Write-Verbose "The [$($VsanCluster.Name)] cluster is not VSAN Enabled"
		}
	}
	End { }
	
} #EndFunction Invoke-VSANHealthCheck

Function Get-VsanHealthSilentChecks {

<#
.SYNOPSIS
    Function : Get-VsanHealthSilentChecks
    EMail    : Xavier.avrillier@gmail.com
    Date     : 25/04/2018
    Info     : Display all health checks that have been silenced.
.DESCRIPTION
Display all health checks that have been silenced.
.PARAMETER Cluster
Specify a Cluster object (Get-Cluster)
#>

param(
    [parameter(ValueFromPipeline=$True,Mandatory=$True)]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl]
    $Cluster
)

Process {

    $VsanView = Get-VsanView | Where MoRef -eq "VsanVcClusterHealthSystem-vsan-cluster-health-system"

    $SilentCheckId = $vsanview.VsanHealthGetVsanClusterSilentChecks($cluster.id)

    $vsanview.VsanQueryAllSupportedHealthChecks() | where testid -in $SilentCheckId

}

}


Function Set-VsanHealthSilentChecks {

<#
.SYNOPSIS
    Function : Set-VsanHealthSilentChecks
    EMail    : Xavier.avrillier@gmail.com
    Date     : 25/04/2018
    Info     : Silence or unsilence a VSAN Health check
.DESCRIPTION
Silencing and unsilencing of VSAN health checks cannot be done in the web ui.
For example, a health check can be in a warning state if no internet connection exists which may be by design.
.PARAMETER Cluster
Specify a Cluster object (Get-Cluster)
.PARAMETER TestId
Id(s) of the health check(s) to silence or unsilence.
This can be found with the Get-VsanHealthChecks function.
.PARAMETER CheckState
Silence of Unsilence. Will be applied to all healthchecks specified in TestId.  
#>

param(
    [parameter(ValueFromPipeline=$True,Mandatory=$True)]
    [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl]
    $Cluster,

    [parameter(Mandatory=$True)]
    [string[]]
    $TestId,

    [parameter(Mandatory=$True)]
    [validateset("Silence","Unsilence")]
    [string[]]
    $CheckState
)

Process {

            switch ($CheckState) {

    "Silence"   {$add = $TestId; $remove = $null}
    "Unsilence" {$remove = $TestId; $add = $null}

    }

    $VsanView = Get-VsanView | Where MoRef -eq "VsanVcClusterHealthSystem-vsan-cluster-health-system"

    $vsanview.VsanHealthSetVsanClusterSilentChecks($cluster.id,$add,$remove) | Out-Null

    $SilentCheckId = $vsanview.VsanHealthGetVsanClusterSilentChecks($cluster.id)

    $vsanview.VsanQueryAllSupportedHealthChecks() | where testid -in $SilentCheckId

}

}


Function Get-VsanHealthChecks {

<#
.SYNOPSIS
    Function : Get-VsanHealthChecks
    EMail    : Xavier.avrillier@gmail.com
    Date     : 25/04/2018
    Info     : Display the health state of objects for a VSAN cluster
.DESCRIPTION
Health of checks for a VSAN cluster.
Equivalent in vSphere web client to Cluster>Monitor>VSAN>Health (expanded view)
.PARAMETER Cluster
Specify a Cluster object (Get-Cluster)
.PARAMETER Health
Filter checks by Green, Yellow or Red state.
.PARAMETER DontFetchFromCache
By default if this switch is not set, the Health status will be pulled from the latest cached ones.
If it is set to $true the execution will take more time but will be up to date.  
#>

param(
    [parameter(ValueFromPipeline=$True,Mandatory=$True)]
    $Cluster,

    [validateset("Green","Yellow","Red","skipped")]
    [string[]]
    $Health = @("Green","Yellow","Red","skipped"),

    [switch]
    $DontFetchFromCache
)

Process {

    $VsanView = Get-VsanView | Where MoRef -eq "VsanVcClusterHealthSystem-vsan-cluster-health-system"

    $status = $vsanview.VsanQueryVcClusterHealthSummary($cluster.id,$null,$check.testid,$true,"groups",!$DontFetchFromCache,"defaultView")

    foreach ($group in $status.Groups) {

        $group.grouptests | where TestHealth -in $Health | select TestHealth,@{l="TestId";e={$_.testid.split(".") | select -last 1}},TestName,TestShortDescription,@{l="Group";e={$group.GroupName}}

    }

}

}


Function Get-VsanHealthGroups {

<#
.SYNOPSIS
    Function : Get-VsanHealthGroups
    EMail    : Xavier.avrillier@gmail.com
    Date     : 25/04/2018
    Info     : Display the health state per groups for a VSAN cluster
.DESCRIPTION
Health of group of checks for a VSAN cluster.
Equivalent in vSphere web client to Cluster>Monitor>VSAN>Health (collapsed view)
.PARAMETER Cluster
Specify a Cluster object (Get-Cluster)
.PARAMETER Health
Filter checks by Green, Yellow or Red state.
.PARAMETER DontFetchFromCache
By default if this switch is not set, the Health status will be pulled from the latest cached ones.
If it is set to $true the execution will take more time but will be up to date.  
#>

param(
    [parameter(ValueFromPipeline=$True,Mandatory=$True)]
    $Cluster,

    [validateset("Green","Yellow","Red")]
    [string[]]
    $Health = @("Green","Yellow","Red"),

    [switch]
    $DontFetchFromCache
)

Process {
    
    $VsanView = Get-VsanView | Where MoRef -eq "VsanVcClusterHealthSystem-vsan-cluster-health-system"

    $VsanHealthChecks = $vsanview.VsanQueryVcClusterHealthSummary($cluster.id,$null,$check.testid,$true,"groups",!$DontFetchFromCache,"defaultView")

    foreach ($group in $VsanHealthChecks.groups) {

        $Green  = $group.GroupTests | where testhealth -eq "green"
        $Yellow = $group.GroupTests | where testhealth -eq "Yellow"
        $Red    = $group.GroupTests | where testhealth -eq "Red"

        [pscustomobject]@{

            GroupId      = $Group.GroupId.replace("com.vmware.vsan.health.test.","")
            GroupName    = $group.GroupName
            GroupHealth  = $group.GroupHealth
            ChecksGreen  = $Green.Count
            ChecksYellow = $Yellow.Count
            ChecksRed    = $red.Count

        }

    }

}

}

$test = get-cluster | Get-VSANHealthSummary
$diskspace = Get-VsanSpaceUsage 
[int]$UsedDiskSpace = $diskspace.CapacityGB - $diskspace.FreeSpaceGB
[int]$percentUsedDiskspace = (($UsedDiskSpace / [int]$diskspace.CapacityGB)*100)
Add-Content -Path $file -value $UsedDiskSpace 


$XMLFile = "C:\aenc\vSan\vsan.xml"
#create new clean XML file
New-Item -Path $XMLFile -ItemType File -Force

#Put basic data in XML file
$xmlWriter = New-Object System.XMl.XmlTextWriter($XMLFile,$Null)
$xmlWriter.Formatting = 'Indented'
$xmlWriter.Indentation = 1
$XmlWriter.IndentChar = "`t"
$xmlWriter.WriteStartDocument()
$xmlWriter.WriteComment('XML file for VSAN health information')
$xmlWriter.WriteStartElement('VSAN')
$xmlWriter.WriteEndElement()
$xmlWriter.WriteEndDocument()
$xmlWriter.Flush()
$xmlWriter.Close()

 # Create the Initial  Node
 $xmlDoc = [System.Xml.XmlDocument](Get-Content $XMLFile);
 $listCollectionNode = $xmlDoc.CreateElement("List")
 $xmlDoc.SelectSingleNode("//VSAN").AppendChild($listCollectionNode)
 $listCollectionNode.SetAttribute("Title", "VSAN Health Info")
 $xmlDoc.Save($XMLFile)

#put data in XML file
$ruimte = $test.DiskSpaceHealth
$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("DiskSpaceHealth"));
$DiskSpaceHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($ruimte));

$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("UsedDiskCapacity"));
$DiskCalcHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($UsedDiskSpace));

$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("UsedDiskpercCapacity"));
$DiskCalcPercHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($percentUsedDiskspace));

$schijf = $test.DiskHealth
$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("DiskHealth"));
$DiskHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($schijf));

$summary = $test.OverallHealth
$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("Summary"));
$SummaryHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($summary));

$netwerk = $test.NetworkHealth
$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("Network"));
$NetworkHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($netwerk));

$vmhcl = $test.HclDbHealth
$ListItems = $listCollectionNode.AppendChild($xmlDoc.CreateElement("HCL"));
$HCLHealth = $ListItems.AppendChild($xmlDoc.CreateTextNode($vmhcl));

$xmlDoc.Save($XMLFile)

#Troep opruimen (vSan Health Disposable opbjects)
$vsan_Health_Object = (get-vm | Where-Object {$_.name -like "*vsan-health*"})
Foreach($check in $vsan_Health_Object){
if($vsan_Health_Object.Notes -contains "Created by VSAN HealthCheck. Delete if left over") {Remove-VM $check.name -DeletePermanently -Confirm:$false}
}
#Check of er nog disposable objecten staan
$vsan_Health_Object = (get-vm | Where-Object {$_.name -like "*vsan-health*"})
$disposableOjects = $vsan_Health_Object.count
if($disposableOjects -eq "0"){Add-Content -Path $file -value "-------------------------------------------------------------"
Add-Content -Path $file -value "Troep is netjes opgeruimd!"}
else{
Add-Content -Path $file -value "-------------------------------------------------------------"
Add-Content -Path $file -value "Er staan nog $disposableObjects objecten die er niet horen!"
$disposableOjects = "0"
}
