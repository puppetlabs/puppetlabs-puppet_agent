[CmdletBinding()]
Param(
	[String]$version,
    [String]$collection = 'puppet'
)
# If an error is encountered, the script will stop instead of the default of "Continue"
$ErrorActionPreference = "Stop"

if ((Get-WmiObject Win32_OperatingSystem).OSArchitecture -match '^32') {
    $arch = "x86"
} else {
    $arch = "x64"
}

if ($version) {
    $msi_name = "puppet-agent-${version}-${arch}.msi"
}
else {
    $msi_name = "puppet-agent-${arch}-latest.msi"
}

$msi_source = "http://downloads.puppetlabs.com/windows/${collection}/${msi_name}"

$date_time_stamp = (Get-Date -format s) -replace ':', '-'
$msi_dest = Join-Path ([System.IO.Path]::GetTempPath()) "puppet-agent-$arch.msi"
$install_log = Join-Path ([System.IO.Path]::GetTempPath()) "$date_time_stamp-puppet-install.log"

function DownloadPuppet {
  Write-Verbose "Downloading the Puppet Agent for Puppet Enterprise on $env:COMPUTERNAME..."

  $webclient = New-Object system.net.webclient

  try {
    $webclient.DownloadFile($msi_source,$msi_dest)
  }
  catch [System.Net.WebException] {
    # If we can't find the msi, then we may not be configured correctly
    if($_.Exception.Response.StatusCode -eq [system.net.httpstatuscode]::NotFound) {
        Throw "Failed to download the Puppet Agent installer: $msi_source"
    }
    # Throw all other WebExceptions
    Throw $_
  }
}

function InstallPuppet {
  $msiexec_args = "/qn /log $install_log /i $msi_dest /norestart"
  Write-Output "Installing the Puppet Agent on $env:COMPUTERNAME..."
  $msiexec_proc = [System.Diagnostics.Process]::Start('msiexec', $msiexec_args)
  $msiexec_proc.WaitForExit()
  if (@(0, 1641, 3010) -NotContains $msiexec_proc.ExitCode) {
    Throw "Installation Failed on: $env:COMPUTERNAME. Exit code: " + $msiexec_proc.ExitCode + " Install Log: $install_log"
  }
}

function Cleanup {
    Write-Output "Deleting $msi_dest and $install_log"
    Remove-Item -Force $msi_dest
    Remove-Item -Force $install_log
}

DownloadPuppet
InstallPuppet
Cleanup

Write-Output "Puppet Agent installed on $env:COMPUTERNAME"
