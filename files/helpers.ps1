<#
.Synopsis
  Write message to location of $Logfile
.Parameter message
  String containing the message to write
.Parameter Logfile
  File location where the installation will log output
#>
function Script:Write-Log {
  param(
    [Parameter(Mandatory=$true)]
    [String] $message,
    [String] $Logfile
  )
  begin {
    "$(Get-Date -Format g) $message" | Out-File -FilePath $Logfile -Append
  }
}
