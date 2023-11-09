gwmi win32_terminalservicesetting -N "root\cimv2\terminalservices" | %{
    if ($_.logons -eq 1){
    write-host "Disabled"
    $logonint = 1
    $logonstring = "Disabled"
    }
    Else {
        switch ($_.sessionbrokerdrainmode)
        {
            0 {
            write-host "sessions zijn Enabled"
            $logonint = 0
            $logonstring = "Enabled"
            }
            1 {
            Write-host "Logon staat op DrainUntilRestart"
            $logonint = 2
            $logonstring = "DrainUntilRestart"
            }
            2 {
            Write-host "Logons staat op Drain"
            $logonint = 3
            $logonstring = "Drain"           
            }
            default {"something's not right here!"}
        }
    }
}
 $%id%LogonStatus%id% = $logonstring