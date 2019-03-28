# install_puppet.ps1
<#
.Synopsis
  Install or upgrade puppet-agent
.Description
  This script will install or upgrade puppet-agent on a windows machine from the MSI file at $Source.
  If the script is supplied with $PuppetPID it will wait on the $PuppetPID before attempting to perform
  an upgrade.
.Parameter PuppetPID
  The process ID of puppet to wait on before executing an upgrade. Note that all puppet processes must shut
  down before an installation can occur
.Parameter Source
  The location of the new puppet-agent MSI installer
.Parameter Logfile
  File location where the installation will log output
.Parameter InstallDir
  Optionally change the default location where puppet-agent will be installed
.Parameter PuppetMaster
  The location of the puppet master
.Parameter PuppetStartType
  Optionally change the default start type of puppet
.Parameter InstallArgs
  Provide any extra argmuments to the MSI installation
.Parameter UseLockedFilesWorkaround
  Set to $true to enable execution of the puppetres.dll move workaround. See https://tickets.puppetlabs.com/browse/MODULES-4207
#>
[CmdletBinding()]
param(
  # PuppetPID _must_ come first!, this script needs PuppetPID to be a positional parameter to execute
  # correctly from the module.
  [parameter(Position=0)]
  [String] $PuppetPID,
  [String] $Source,
  [String] $Logfile,
  [AllowEmptyString()]
  [String] $InstallDir,
  [AllowEmptyString()]
  [String] $PuppetMaster,
  [AllowEmptyString()]
  [String] $PuppetStartType,
  [AllowEmptyString()]
  [String] $InstallArgs,
  [switch] $UseLockedFilesWorkaround
)
# Find-InstallDir, Move-PuppetresDLL and Reset-PuppetresDLL serve as a workaround for older
# installations of puppet: we used to need to move puppetres.dll out of the way during puppet
# upgrades because the file would lock and cause network stack restarts.
# See https://tickets.puppetlabs.com/browse/MODULES-4207
<#
.Synopsis
  Fetch the location of the puppet installation from the registry
#>
function Script:Find-InstallDir {
  begin {
    if (Get-ItemProperty -Path "HKLM:\SOFTWARE\Puppet Labs\Puppet" -Name RememberedInstallDir64 -ErrorAction SilentlyContinue) {
      return (Get-ItemProperty -Path "HKLM:\SOFTWARE\Puppet Labs\Puppet").RememberedInstallDir64
    } elseif (Get-ItemProperty -Path "HKLM:\SOFTWARE\Puppet Labs\Puppet" -Name RememberedInstallDir -ErrorAction SilentlyContinue) {
      return (Get-ItemProperty -Path "HKLM:\SOFTWARE\Puppet Labs\Puppet").RememberedInstallDir
    } else {
      return $null
    }
  }
}

<#
.Synopsis
  Move/rename puppetres.dll to a temporary location
#>
function Script:Move-PuppetresDLL {
  begin {
    $rand_string = [String[]](Get-Random)
    $temp_puppetres = "$env:temp\$rand_string-lockeddll"
    # _Never_ use the $InstallDir top-level parameter to try and find the InstallDir
    # for the puppetres workaround. The workaround should _always_ fetch the InstallDir
    # from the registry. This is so a user can specify a different InstallDir than the
    # directory where the current package is installed and the workaround will still work
    # for the already installed package
    $InstallDir = Find-InstallDir
    if (Test-Path "$InstallDir\puppet\bin\puppetres.dll") {
      Write-Log "Moving puppetres.dll to $temp_puppetres"
      Move-Item -Path "$InstallDir\puppet\bin\puppetres.dll" -Destination $temp_puppetres
      # Remove-Item -Path $temp_puppetres
    }
    return $temp_puppetres
  }
}

<#
.Synopsis
  Restore puppetres.dll to the original location. This should only be used when an installation fails
.Parameter temp_puppetres
  Location of the temporary puppetres.dll file.
#>
function Script:Reset-PuppetresDLL {
  param(
    [Parameter(Mandatory=$true)]
    [AllowNull()]
    [AllowEmptyString()]
    [String] $temp_puppetres
  )
  begin {
    if (!$temp_puppetres) {
      Write-Log "puppetres.dll Never moved, continuing..."
      return
    }
    # _Never_ use the $InstallDir top-level parameter to try and find the InstallDir
    # for the puppetres workaround. The workaround should _always_ fetch the InstallDir
    # from the registry. This is so a user can specify a different InstallDir than the
    # directory where the current package is installed and the workaround will still work
    # for the already installed package
    $InstallDir = Find-InstallDir
    if ((Test-Path $temp_puppetres) -and -not (Test-Path "$InstallDir\puppet\bin\puppetres.dll")) {
      Write-Log "Restoring puppetres.dll"
      Move-Item -Path $temp_puppetres -Destination "$InstallDir\puppet\bin\puppetres.dll"
    }
  }
}

<#
.Synopsis
  Write message to location of $Logfile
.Parameter message
  String containing the message to write
#>
function Script:Write-Log {
  param(
    [Parameter(Mandatory=$true)]
    [String] $message
  )
  begin {
    "$(Get-Date -Format g) $message" | Out-File -FilePath $Logfile -Append
  }
}

<#
.Synopsis
  Take control of the installation lockfile, fail if the lock
  already exists
.Parameter install_pid_lock
  Location of the installation pid lock file
#>
function Script:Lock-Installation {
  param(
    [Parameter(Mandatory=$true)]
    [String] $install_pid_lock
  )
  begin {
    Write-Log "Locking installation"
    if (Test-Path $install_pid_lock) {
      Write-Log "Another process has control of $install_pid_lock! Cannot lock, exiting..."
      throw
    } else {
      $PID | Out-File -NoClobber -FilePath $install_pid_lock
    }
    Write-Log "Locked"
  }
}

<#
.Synopsis
  Release control of the installation lockfile
.Parameter install_pid_lock
  Location of the installation pid lock file
#>
function Script:Unlock-Installation {
  param(
    [Parameter(Mandatory=$true)]
    [String] $install_pid_lock
  )
  begin {
    Write-Log "Unlocking installation"
    if (Test-Path $install_pid_lock) {
      if ((Get-Content $install_pid_lock) -ne $PID) {
        Write-Log "Another process has control of $install_pid_lock! Cannot unlock, exiting..."
      } else {
        try {
          Remove-Item -Force $install_pid_lock | Out-Null
          Write-Log "Unlocked"
        } catch {
          Write-Log $_
        }
      }
    }
  }
}

<#
.Synopsis
  Collect the current state of puppet-agent services
.Parameter service_names
  an array of service names to save the state for
#>
function Script:Read-PuppetServices {
  param(
    [Parameter(Mandatory=$true)]
    [Array] $service_names
  )
  begin{
    $services = @()
    foreach ($service_name in $service_names) {
      # Let Get-Service silently continue if the service doesn't exist. This is
      # so we can ignore mcollective when it doesn't exist (i.e. agent > 6.0.0)
      $service_entry = Get-Service $service_name -ErrorAction SilentlyContinue
      # The StartType entry was only added to 'Get-Service' in powershell 4, so
      # we need to use WMI to fetch it for older versions of windows
      if ($service_entry) {
        $start_type = (Get-WmiObject -Class Win32_Service -Property StartMode -Filter "Name='$service_name'").StartMode.Replace('Auto', 'Automatic')
        Write-Log "Fetched Service $service_name status: $($service_entry.Status), StartType: $start_type"
        $services += @{ 'Name' = $service_name; 'Status' = $service_entry.Status; 'StartType' = $start_type }
      } else {
        Write-Log "Service $service_name does not exist, continuing..."
      }
    }
    return $services
  }
}

<#
.Synopsis
  Restore the state of puppet-agent services
.Parameter services
  An array containing hashtables of service statuses and start types in the form:
  {'Name' = 'service name'; 'Status' = 'service status'; 'StartType' = 'service start type'}
#>
function Script:Reset-PuppetServices {
  param(
    [Parameter(Mandatory=$true)]
    [AllowNull()]
    [Array] $services
  )
  begin{
    if (!$services) {
      Write-Log "Services to reset is empty..."
      return
    }
    foreach ($service in $services) {
      # We need to check if the service still exists after upgrade, since
      # an upgrade from agent < 6 to agent >= 6 will have an mcollective
      # service before upgrade, but no mcollective service after
      if (Get-Service $service.Name -ErrorAction SilentlyContinue) {
        Write-Log "Restoring service state for $($service.Name)"
        Set-Service $service.Name -StartupType $service.StartType
        Set-Service $service.Name -Status $service.Status
      } else {
        Write-Log "Get-Service failed to fetch $($service.Name), continuing..."
      }
    }
  }
}

# ************** Execution start **************
$ErrorActionPreference = "Stop"
$service_names=@(
  "puppet",
  "pxp-agent",
  "mcollective"
)
try {
  $state_dir = (puppet.bat config print statedir --environment production)
  Write-Log "Installation PID:$PID"
  $install_pid_lock = Join-Path -Path $state_dir -ChildPath 'puppet_agent_upgrade.pid'
  Lock-Installation $install_pid_lock
  if ($PuppetPID) {
    # Wait for the puppet run to finish
    #
    # We must wait for the puppet agent to finish applying its catalog before we
    # stop all of our services. Otherwise if the catalog has additional resources
    # that manage our services (e.g. such as those from the PE module), then the
    # install will fail to proceed.
    Write-Log "Waiting for puppet to stop, PID:$PuppetPID"
    $pup_process = Get-Process -ID $PuppetPID -ErrorAction SilentlyContinue
    if ($pup_process) {
      if (!$pup_process.WaitForExit(120000)){
        Write-Log "ERROR: Timed out waiting for puppet!"
        throw
      }
    } else {
      Write-Log "Puppet Already finished"
    }
  }
  $services_before = Read-PuppetServices $service_names
  # We *must* shutdown all puppet-agent services for the MSI installation to correctly
  # work without requiring a restart.
  foreach($service in $service_names) {
    $serv_exists = Get-Service -Name $service -ErrorAction SilentlyContinue
    if ($serv_exists) {
      Write-Log "Stopping $($service) before upgrade"
      Stop-Service $service
    }
  }
  # Wait for any pxp-agent process still hanging around
  #
  # There is a known problem for pxp-agent shutdown: there are cases where after service
  # shutdown pxp-agent processes are still open. See https://tickets.puppetlabs.com/browse/FM-7628
  # for more details on the symptoms of this.
  Write-Log "Waiting for pxp-agent processes to stop"
  Get-Process -Name "pxp-agent" -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_) {
      # wait on each process for 2 minutes (120000 milliseconds)
      if (!$_.WaitForExit(120000)){
        Write-Log "ERROR: Timed out waiting for pxp-agent!"
        throw
      }
    }
  }
  if ($UseLockedFilesWorkaround) {
    $temp_puppetres = Move-PuppetresDLL
  }
  $msi_arguments = "/qn /norestart /i `"$Source`" /l*vx+ `"$Logfile`""
  if ($InstallDir) {
    $msi_arguments += " INSTALLDIR=`"$InstallDir`""
  }
  if ($PuppetMaster) {
    $msi_arguments += " PUPPET_MASTER_SERVER=`"$PuppetMaster`""
  }
  if ($PuppetStartType) {
    $msi_arguments += " PUPPET_AGENT_STARTUP_MODE=`"$PuppetStartType`""
  }
  $msi_arguments += " $InstallArgs"
  Write-Log "Beginning MSI installation with Arguments: $msi_arguments"
  Write-Log "****************************** Begin msiexec.exe output ******************************"
  $startInfo = New-Object System.Diagnostics.ProcessStartInfo('msiexec.exe', $msi_arguments)
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true
  $invocationId = [Guid]::NewGuid().ToString()
  $msi_process = New-Object System.Diagnostics.Process
  $msi_process.StartInfo = $startInfo
  $msi_process.EnableRaisingEvents = $true
  $exitedEvent = Register-ObjectEvent -InputObject $msi_process -EventName 'Exited' -SourceIdentifier $invocationId
  $msi_process.Start() | Out-Null
  # park current thread until the PS event is signaled upon process exit
  # OR the timeout has elapsed
  $waitResult = Wait-Event -SourceIdentifier $invocationId
  Write-Log "****************************** End msiexec.exe output ******************************"
  if (($msi_process.ExitCode -eq 3010) -or ($msi_process.ExitCode -eq 1641) ){
    Write-Log "WARNING: msiexec.exe returned $($msi_process.ExitCode) and has flagged the system for restart!!!"
  } elseif ($msi_process.ExitCode -ne 0){
    Write-Log "ERROR: msiexec.exe installation failed!!! Return code $($msi_process.ExitCode)"
    throw
  }
} catch {
  Write-Log "ERROR: $_"
  if ($UseLockedFilesWorkaround) {
    Reset-PuppetresDLL $temp_puppetres
  }
  "$_" | Out-File -FilePath (Join-Path -Path $state_dir -ChildPath 'puppet_agent_upgrade_failure.log')
} finally {
  Reset-PuppetServices $services_before
  Unlock-Installation $install_pid_lock
}
