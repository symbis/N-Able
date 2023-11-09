Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$psThreshold = $psThresholdsDatabase
$DBs = Get-MailboxDatabase -status 

$psAantalDatabases = $DBs.Count
$psAantalDatabasesFailed = 0
$psDatabaseNameFailed = ""
$psReasonFailed = ""
$psDatabaseSize = ""
$psDatabaseMountStatus = ""

foreach($DB in $DBs)
{

    $psDatabaseMountStatus += $DB.Mounted.ToString() + " "
    $psDatabaseSize += [string]$DB.DatabaseSize.ToGB() + "GB "
    if($DB.Mounted.ToString() -ne "True")
    {
        #Er is een database gevonden welke niet gemounted is.
        if($psAantalDatabasesFailed -eq 0)
        {
            $psReasonFailed = [string]$DB.Name + " is niet gemounted"
            $psDatabaseNameFailed = [string]$DB.Name
        }
        else
        {
            $psReasonFailed = $psReasonFailed + " , " +[string]$DB.Name + " is niet gemounted"
            $psDatabaseNameFailed = $psDatabaseNameFailed + " , " + [string]$DB.Name
        }        
        $psAantalDatabasesFailed = $psAantalDatabasesFailed + 1
    }

    if($DB.DatabaseSize.ToGB() -ge $psThreshold)
    {
        #er is een database gevonden welke de thresholds waarde heeft overschreden
        if($psAantalDatabasesFailed -eq 0)
        {
            $psReasonFailed = [string]$DB.Name + " is groter dan " + $psThreshold + " GB"
            $psDatabaseNameFailed = [string]$DB.Name
        }
        else
        {
            $psReasonFailed = $psReasonFailed + " , " + [string]$DB.Name + " is groter dan " + $psThreshold + " GB"
            $psDatabaseNameFailed = $psDatabaseNameFailed + " , " + [string]$DB.Name
        }
        $psAantalDatabasesFailed = $psAantalDatabasesFailed + 1
    }
}