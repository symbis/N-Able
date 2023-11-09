$scriptblock = {
$LogFilter = Get-WinEvent -FilterHashtable @{ LogName = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"; ID = 40;StartTime=[datetime]::Today;} -ErrorAction SilentlyContinue | Where-Object -Property Message -Like "*3489660929*"
	foreach($Log in $LogFilter)
	{
		$sessieID = $Log.Properties[8]
		$endtime = $log.TimeCreated + 10000000 
		$LogFilterActions = Get-WinEvent -FilterHashtable @{ LogName = "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational"; ID = 24;StartTime=$log.TimeCreated;Endtime=$endtime} -ErrorAction SilentlyContinue | Where-Object -Property Message -Like "*$sessieID*" 
		#foreach($LogAction in $LogFilterActions)
		#{
			#$LogAction.TimeCreated
			#$LogAction.Properties[0]
			#$Log.Message
			#Write-Host "`n"
		#}
	}
	#Write-Host $env:computername "heeft" $LogFilter.Count " disconnects vandaag" 
	$logFilter.Count
}
$servers = @('SRV-SCH-TS01','SRV-SCH-TS02','SRV-SCH-TS03','SRV-SCH-TS04','SRV-SCH-TS05','SRV-SCH-TS06','SRV-SCH-TS07','SRV-SCH-TS08')
$totaldisconnects = ""
foreach($server in $servers)
{
   $command = Invoke-Command -ComputerName $server -ScriptBlock $scriptblock
  
   [string]$totaldisconnects += [string]$command + ", "
}
