<#
.Synopsis
  Read the ProductVersion from a Windows Installer MSI file
.Description
  This script will check if the versions from the .msi file and the $RequiredVersion match, to ensure that only
  the .msi with the wanted version is installed.
.Parameter RequiredVersion
  The version that is required to be installed
.Parameter Msi
  The file name of the MSI file, or full path
.Parameter Logfile
  File location where the installation will log output
#>
param (
    [String] $RequiredVersion,
    [IO.FileInfo] $Msi,
    [String] $Logfile
)

# $PSScript is only available in Powershell >= 3.
if(!$PSScriptRoot){ $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
. "$PSScriptRoot\helpers.ps1"

Write-Log "Checking puppet-agent.msi version and expected puppet-agent version.." $Logfile
try {
  if (!(Test-Path $Msi.FullName)) {
    Write-Error "ERROR: File '${Msi.FullName}' does not exist"
    Write-Log "ERROR: File '${Msi.FullName}' does not exist" $Logfile
    throw
  }
  $Msi_version = ""

  # MSI versions in dev/nightly builds are the same as released
  # builds, so only match MAJOR.MINOR.PATCH.
  if ($RequiredVersion -match "(\d+.\d+.\d+).\d+") {
    $RequiredVersion = $Matches[1]
  }

  try {
    $windowsInstaller = New-Object -com WindowsInstaller.Installer
    $database = $windowsInstaller.GetType().InvokeMember(
        "OpenDatabase", "InvokeMethod", $Null,
        $windowsInstaller, @($Msi.FullName, 0)
    )

    $q = "SELECT Value FROM Property WHERE Property = 'ProductVersion'"
    $View = $database.GetType().InvokeMember(
        "OpenView", "InvokeMethod", $Null, $database, ($q)
    )

    $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
    $record = $View.GetType().InvokeMember( "Fetch", "InvokeMethod", $Null, $View, $Null )
    $Msi_version = $record.GetType().InvokeMember( "StringData", "GetProperty", $Null, $record, 1 )

  } catch {
    Write-Error "ERROR: Failed to get MSI file version: ${_}."
    Write-Log "ERROR: Failed to get MSI file version: ${_}." $Logfile
    throw
  }
  if ($Msi_version -eq $RequiredVersion) {
    Write-Log ".msi file version and expected puppet-agent version match (${Msi_version})" $Logfile
    exit 0
  } else {
    Write-Output "ERROR: The expected puppet-agent version(${RequiredVersion}) does NOT match the .msi version ${Msi_version}.  Installation will STOP!"
    Write-Log "ERROR: The expected puppet-agent version(${RequiredVersion}) does NOT match the .msi version ${Msi_version}. Installation will STOP!" $Logfile
    throw
  }
} catch {
  Write-Log "ERROR: $_" $Logfile
  exit 1
}
