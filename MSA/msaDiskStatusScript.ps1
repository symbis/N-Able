$Processed = [regex]::split($ShowDisks, '-{2,}') | ? {$_.Length -gt 0}

$Processed = $Processed[1]
$RMatches = @()
$CountSparedisks = 0
$CountTotalDisks = 0
$diskStatus = ""
$faileddiskID= ""

$Lines = $Processed.Split([Environment]::NewLine) | ? {$_.Length -gt 0}



Foreach ($L in $Lines) {
  IF ($L -match "Global SP") {
    $CountSparedisks++
  }
  IF ($L -match "POOL" -or $L -match "Global SP") {
    $CountTotalDisks++
  }
}

Foreach ($L in $Lines) {
  IF ($L -match '\b\d+\.\d+\b') {
    $RMatches += $Matches.Values    
  }
}

$Processed = [regex]::split($Processed, '\b\d+\.\d+\b')

For ($I = 0; $I -lt $RMatches.Length; $I++) {
  Switch -Wildcard ($Processed[($i+1)]) {
      "* Degraded*" {
      $diskStatus += " Degraded"
      $faileddiskID += " " + $RMatches[$i]
      }

      "* Fault*" {
      $diskStatus += " Fault"
      $faileddiskID += " " + $RMatches[$i]
    } 
  }
  if($diskStatus -eq ""){$diskStatus = "OK"}
}


















