  <#
.SYNOPSIS 
Get locations where user is used.
.DESCRIPTION
Check all servers if specified user is used in services or task scheduler.
.NOTES
Created by Barend vd Dussen
Date: 26-10-2023
Inputs: $userName - (default domain admin.), $runAsUser, $runAsPassword
Outputs: [string]$serversWithServices, [string]$serverswithScheduledTasks, [string]$locationLogFile, [int]$countserversWithServices,[int]$countserversWithScheduledTasks
Version: 1.0
Release Notes
V1.0: Initial release
#> 

#uncomment variable when running manually 
$userName = "Administrator"

#comment variables when running manually
#$password = ConvertTo-SecureString $runAsPassword -AsPlainText -Force
#$credentials = New-Object System.Management.Automation.PSCredential ($runAsUser, $password)


$PathLogFile = "C:\Symbis\"
$locationLogFile = $PathLogFile + "LogFileUserLocations.txt"
$table = @()
$errors = @()
$errors += "Raw Output: "
$processedItems = 0

#initialize Progressbar
$progressParams = @{
    Activity = "Processing Items"
    Status = "In Progress"
    PercentComplete = 0
}

if($userName){
    #check if user exist in AD.
    try
    {
        #Try to get all neccessary information
        $user = Get-ADUser -identity $userName
        $pre2000Name = $env:userdomain + "\" + $user.Name
        $userName = $user.Name
        $upn = $user.UserPrincipalName
        $servers = Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} -Properties OperatingSystem 
        #$servers = Get-ADComputer -Filter {Name -Like "MNGMT-02*"} -Properties OperatingSystem   
        if(($servers.getType()).BaseType.Name -ne "Array"){
            $totalServers = 1
        }
        else{
            $totalServers = $servers.count  
        } 
   
    }
    catch {
        #user not found.
        Write-Host "Problems with founding the user"
        $errors += "Problems with founding the user"
    }
}else{
    #no input
    Write-Host "No User specified in the input of this script."
    $errors += "No User specified in the input of this script."
} 

#check if user and server variable aren't empty.
if($user -ne '' -and $serverList -ne ''){
    foreach($server in $servers){
        #write progressbar        
        $processedItems++
        $progressParams.PercentComplete = [math]::Round(($processedItems / ($totalServers *2)) * 100)        
        Write-Progress @progressParams
        #clear variables.
        if($services){clear-variable -name "services"}
        if($servicesUsedByUser){clear-variable -name "servicesUsedByUser"}
        if($tasks){clear-variable -name "tasks"}
        if($tasksUsedByUser){clear-variable -name "tasksUsedByUser"}
        #check if server is reachable by WinRM/5985
        if(test-netconnection $server.name -CommonTCPPort WINRM -InformationLevel quiet){
        #check on all servers for services with those user.
            try {
                if($credentials){
                    $session = New-pssession -ComputerName $server.Name -errorAction SilentlyContinue -Credential $credentials
                }else{
                    $session = New-pssession -ComputerName $server.Name -errorAction SilentlyContinue 
                }
                if($session){
                     $services = Invoke-Command -session $session -ScriptBlock { Get-CimInstance -ClassName Win32_Service -ErrorAction SilentlyContinue | Select-Object DisplayName, Name, State, StartName }
                     Remove-PSSession -Session $session  
                }
                            
                $servicesUsedByUser = $services | Where-Object {$_.StartName -like $pre2000Name}
                if($servicesUsedByUser){
                    #Services found with this user on server
                    foreach($serviceUsedByUser in $servicesUsedByUser)
                    {
                        Write-Host "Found on server" $server.Name "the following services with the user" $user.Name": "$serviceUsedByUser.DisplayName
                        $errors += "Found on server " + $server.Name + " the following services with the user " + $user.Name + ": " +$serviceUsedByUser.DisplayName                
                    } 
                    $serversWithServices += $server.Name
                    $serversWithServices += ", "
                    countserversWithServices += 1                   
                }
            }
            catch {
                #unable to get services
                #Write-Host $error[0]
                Write-Host "Unable to get services from " + $server
                $errors += "Unable to get services from " + $server
            }
            #write progressbar
            $processedItems++
            $progressParams.PercentComplete = [math]::Round(($processedItems / ($totalServers *2)) * 100)
            Write-Progress @progressParams
            #check on all servers for scheduled task with those user.
            try {
                if($credentials){
                    $session = New-pssession -ComputerName $server.Name -errorAction SilentlyContinue -Credential $credentials
                }else{
                    $session = New-pssession -ComputerName $server.Name -errorAction SilentlyContinue 
                }
                if($session){
                     $tasks = Invoke-Command -session $session -ScriptBlock { Get-ScheduledTask -CimSession $server.Name -ErrorAction SilentlyContinue }
                     Remove-PSSession -Session $session  
                }
                $tasksUsedByUser = $tasks | Where-Object { ($_.Principal.UserId -like "$userName" -or $_.Principal.UserId -like "$pre2000Name" ) -and $_.Principal.LogonType -eq "Password" }
                if($tasksUsedByUser){
                    #Services found with this user on server
                    foreach($taskUsedByUser in $tasksUsedByUser)
                    {
                        Write-Host "Found on server" $server.Name "the following scheduled Task with the user" $user.Name": "$taskUsedByUser.TaskName
                        $errors += "Found on server " + $server.Name + " the following scheduled Task with the user " + $user.Name + ": " +$taskUsedByUser.TaskName               
                    }
                    $serverswithScheduledTasks += $server.Name
                    $serverswithScheduledTasks += ", "  
                    $countserversWithScheduledTasks += 1                 
                }
            }
            catch {
                #unable to get Scheduled Tasks
                #Write-Host $error[0]
                Write-Host "Unable to get scheduled Tasks from" $server
                $errors += "Unable to get scheduled Tasks from " + $server
            }
            $table += [PSCustomObject]@{
                Name = $server.name
                Services = $servicesUsedByUser.Name -join ', '
                TaskSchedulers = $tasksUsedByUser.TaskName -join ', '
            }
        }
        else{
            #server not reachable by WINRM.
            Write-Host $server.Name"Not reachable!"
            $errors += $server.Name + " Not reachable!" 
        }
    }

}

#export table to logFile
if(!(test-path $PathLogFile)){
    New-Item -ItemType Directory -Path $PathLogFile
}
$table | Format-Table -AutoSize | Out-File -FilePath $locationLogFile
$errors | Out-File -FilePath $locationLogFile -Append

# Complete the progress bar
$progressParams.Status = "Completed"
$progressParams.PercentComplete = 100
Write-Progress @progressParams 
 
