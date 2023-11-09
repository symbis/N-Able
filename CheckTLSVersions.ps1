
function check-sslServer-2.0 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Name 'DisabledByDefault'-ErrorAction Stop)
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "SSL2Server" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "SSL2Server" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "SSL2Server" -Value 2}   
}
function check-sslClient-2.0 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' -name 'DisabledByDefault'-ErrorAction Stop).DisabledByDefault
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "SSL2Client" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "SSL2Client" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "SSL2Client" -Value 2}   
}
function check-sslServer-3.0 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Name 'DisabledByDefault'-ErrorAction Stop)
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "SSL3Server" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "SSL3Server" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "SSL3Server" -Value 2}   
}
function check-sslClient-3.0 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' -name 'DisabledByDefault'-ErrorAction Stop).DisabledByDefault
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "SSL3Client" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "SSL3Client" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "SSL3Client" -Value 2}   
}
function check-tlsServer-1.0 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.0\Server' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.0\Server' -Name 'DisabledByDefault'-ErrorAction Stop)
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls10Server" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls10Server" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls10Server" -Value 2}   
}
function check-tlsClient-1.0 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.0\Client' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.0\Client' -name 'DisabledByDefault'-ErrorAction Stop).DisabledByDefault
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls10Client" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls10Client" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls10Client" -Value 2}   
}
function check-tlsServer-1.1 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.1\Server' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.1\Server' -Name 'DisabledByDefault'-ErrorAction Stop)
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls11Server" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls11Server" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls11Server" -Value 2}   
}
function check-tlsClient-1.1 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.1\Client' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.1\Client' -name 'DisabledByDefault'-ErrorAction Stop).DisabledByDefault
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls11Client" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls11Client" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls11Client" -Value 2}   
}
function check-tlsServer-1.2 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.2\Server' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.2\Server' -Name 'DisabledByDefault'-ErrorAction Stop)
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls12Server" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls12Server" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls12Server" -Value 2}   
}
function check-tlsClient-1.2 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.2\Client' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.2\Client' -name 'DisabledByDefault'-ErrorAction Stop).DisabledByDefault
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls12Client" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls12Client" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls12Client" -Value 2}   
}
function check-tlsServer-1.3 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.3\Server' -name 'Enabled'-ErrorAction Stop).Enabled
        $2 = (Get-ItemPropertyValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.3\Server' -Name 'DisabledByDefault'-ErrorAction Stop) 
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls13Server" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls13Server" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls13Server" -Value 2}   
}
function check-tlsClient-1.3 {
    Try {
        $1 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.3\Client' -name 'Enabled' -ErrorAction Stop).Enabled
        $2 = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\tls 1.3\Client' -name 'DisabledByDefault'-ErrorAction Stop).DisabledByDefault
        if ($1 -eq 1 -or $2 -eq 0 ) {Set-Variable -Scope Global -Name "tls13Client" -Value 0}
        if ($1 -eq 0 -or $2 -eq 1 ) {Set-Variable -Scope Global -Name "tls13Client" -Value 1}
    }
    Catch {Set-Variable -Scope Global -Name "tls13Client" -Value 2}   
}
check-sslServer-2.0
check-sslClient-2.0
check-sslServer-3.0
check-sslClient-3.0
check-tlsServer-1.0
check-tlsClient-1.0
check-tlsServer-1.1
check-tlsClient-1.1
check-tlsServer-1.2
check-tlsClient-1.2
check-tlsServer-1.3
check-tlsClient-1.3


$SSL2Server
$SSL2Client
$SSL3Server
$SSL3Client
$tls10Server
$tls10Client
$tls11Server
$tls11Client
$tls12Server
$tls12Client
$tls13Server
$tls13Client
