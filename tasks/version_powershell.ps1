$rootPath = 'HKLM:\SOFTWARE\Puppet Labs\Puppet'

$reg = Get-ItemProperty -Path $rootPath -ErrorAction SilentlyContinue
if ($null -ne $reg) {
  if ($null -ne $reg.RememberedInstallDir64) {
    $loc = $reg.RememberedInstallDir64+'VERSION'
  } elseif ($null -ne $reg.RememberedInstallDir) {
    $loc = $reg.RememberedInstallDir+'VERSION'
  }
}

if ( ($null -ne $loc) -and (Test-Path -Path $loc) ) {
  Write-Output "{`"version`":`"$(Get-Content -Path $loc -ErrorAction Stop)`",`"source`":`"$($loc.replace('\', '/'))`"}"
} else {
  Write-Output '{"version":null,"source":null}'
}
