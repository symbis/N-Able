Clear
$cipherslists = @('TLS_DHE_RSA_WITH_AES_128_GCM_SHA256','TLS_DHE_RSA_WITH_AES_256_GCM_SHA384','TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256','TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384')
$ciphersenabledkey = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002\' | Select -ExpandProperty Functions
$cipherlistedkey = 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'
[System.Collections.ArrayList]$enabled = @()
[System.Collections.ArrayList]$listed = @()
[System.Collections.ArrayList]$checker = @()

#This will check what cipher suites added on the OS
Function Get-CiphersEnabled {
    ForEach ($a in $ciphersenabledkey){
        If ($cipherslists -eq $a){
            $enabled.Add($a) | Out-Null
        }
    }
}


Function Check-Listed{
    If ($listed.Count -eq 0){
        Write-Host '================================='
        Write-Host 'SSL Cipher Suite Order -  ENABLED'
        Write-Host 'No compatible cipher suite/s listed'
        Write-Host 'Please modify "SSL Cipher Suite Order" and append the cipher suite/s below then reboot the device for changes to take effect'
        "`n"
        $enabled
        "`n"
        Write-Host '================================='
    }Else{
        Write-Host '================================='
        Write-Host 'SSL Cipher Suite Order -  ENABLED'
        Write-Host 'Compatible cipher suite/s listed'
        "`n"
        $listed
        "`n"
        Write-Host '================================='
    }
}

Function Get-Listed {
    $func = (Get-ItemProperty $cipherlistedkey | Select -ExpandProperty Functions) -split ","
    ForEach ($b in $func){
        If ($cipherslists -eq $b){
            $listed.Add($b) | Out-Null
        }
    }
}

Function Check-Order {
    $func = Get-ItemProperty $cipherlistedkey -Name Functions -ErrorAction SilentlyContinue
    If ($func.Length -eq 0){
        Write-Host '=========================='
        Write-Host 'SSL Cipher Suite Order - NOT CONFIGURED / DISABLED'
        Write-Host 'All Default Cipher Suites will be offered for initial handshake'
        Write-Host '=========================='
    }Else{
        $checker.Add($func) | Out-Null
        Get-Listed
    }
}

Get-CiphersEnabled

If ($enabled.Count -ne 0){
    Write-Host '================================='
    Write-Host 'Compatible Cipher Suite/s found:'
    Write-Host '================================='
    $enabled
    Check-Order
    If ($checker.Count -ne 0){
        Check-Listed
    }
}Else{
    Write-Host '================================='
    Write-Host 'Server is not fully patched'
    Write-Host 'No compatible cipher suite/s found'
    Write-Host '================================='
}

