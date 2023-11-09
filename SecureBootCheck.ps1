$firmwareType = $env:firmware_type

if($firmwareType -eq "UEFI")
{
	$SecureBootResult = Confirm-SecureBootUEFI
}
elseif($firmwareType -eq "Legacy")
{
	$SecureBootResult = "Not supported"
}

