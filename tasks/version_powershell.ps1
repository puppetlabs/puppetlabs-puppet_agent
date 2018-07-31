if (Test-Path 'HKLM:\SOFTWARE\Puppet Labs\Puppet') {
  $reg = $(Get-ItemProperty -Path 'HKLM:\SOFTWARE\Puppet Labs\Puppet')
  if (Test-Path $reg.RememberedInstallDir64) {
    $loc = $reg.RememberedInstallDir64+'VERSION'
  } elseif (Test-Path $reg.RememberedInstallDir) {
    $loc = $reg.RememberedInstallDir+'VERSION'
  }
}

if ($loc -ne $null) {
  Write-Output "{`"version`":`"$(type $loc)`",`"source`":`"$($loc.replace('\', '/'))`"}"
} else {
  Write-Output '{"version":null,"source":null}'
}
