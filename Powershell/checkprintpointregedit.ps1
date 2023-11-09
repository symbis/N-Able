#$hostname = "ctx-ssd23-01"
#reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators


For ($i=1; $i -le 10; $i++) {
    if($i -le 9)
    {
        $ctxname = "ctx-SSD23-0" + $i
    }
    else
    {
      $ctxname = "ctx-SSD23-" + $i
    }
    
    
    $result = reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators
    if($result -like "*0x1*")
    {
        $ctxname
        $result = reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators
    }
    }
For ($i=1; $i -le 10; $i++) {
    if($i -le 9)
    {
        $ctxname = "ctx-SSD24-0" + $i
    }
    else
    {
      $ctxname = "ctx-SSD24-" + $i
    }
    
    $result = reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators
    if($result -like "*0x1*")
    {
        $ctxname
        $result = reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators
    }
    }
For ($i=1; $i -le 10; $i++) {
    if($i -le 9)
    {
        $ctxname = "ctx-SSD25-0" + $i
    }
    else
    {
      $ctxname = "ctx-SSD25-" + $i
    }
    $result = reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators
    if($result -like "*0x1*")
    {
        $ctxname
        $result = reg query "\\$ctxname\HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows NT\Printers\PointAndPrint" /v RestrictDriverInstallationToAdministrators
    }
    }