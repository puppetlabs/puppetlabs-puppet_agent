# == Class puppet_agent::install::windows
#
# Private class called from puppet_agent class
#
# Manage the install process for windows specifically
#
class puppet_agent::install::windows(
  $install_dir           = undef,
  $install_options       = [],
  ) {
  assert_private()

  $service_names         = $::puppet_agent::service_names

  $_msi_location = $::puppet_agent::prepare::package::local_package_file_path

  $_install_options = $install_options ? {
    []      => windows_msi_installargs(['REINSTALLMODE="amus"']),
    default => windows_msi_installargs($install_options)
  }

  if (member($::puppet_agent::service_names, 'puppet')) {
    $_agent_startup_mode = 'Automatic'
  } else {
    $_agent_startup_mode = undef
  }

  if $::puppet_agent::msi_move_locked_files {
    $_move_dll_workaround = '-UseLockedFilesWorkaround'
  } else {
    $_move_dll_workaround = undef
  }

  $_timestamp = strftime('%Y_%m_%d-%H_%M')
  $_logfile = windows_native_path("${::env_temp_variable}/puppet-${_timestamp}-installer.log")

  notice ("Puppet upgrade log file at ${_logfile}")
  debug ("Installing puppet from ${_msi_location}")

  $_installps1 = windows_native_path("${::env_temp_variable}/install_puppet.ps1")
  puppet_agent_upgrade_error { 'puppet_agent_upgrade_failure.log': }
  file { "${_installps1}":
    ensure  => file,
    content => file('puppet_agent/install_puppet.ps1')
  }
  exec { 'install_puppet.ps1':
    # The powershell execution uses -Command and not -File because -File will interpolate the quotes
    # in a context like cmd.exe: https://docs.microsoft.com/en-us/powershell/scripting/components/console/powershell.exe-command-line-help?view=powershell-6#-file--
    # Because of this it's much cleaner to use -Command and use single quotes for each powershell param
    command => "${::system32}\\cmd.exe /S /c start /b ${::system32}\\WindowsPowerShell\\v1.0\\powershell.exe \
                  -ExecutionPolicy Bypass \
                  -NoProfile \
                  -NoLogo \
                  -NonInteractive \
                  -Command ${_installps1} \
                          -PuppetPID ${::puppet_agent_pid} \
                          -Source '${_msi_location}' \
                          -Logfile '${_logfile}' \
                          -InstallDir '${install_dir}' \
                          -PuppetMaster '${::puppet_master_server}' \
                          -PuppetStartType '${_agent_startup_mode}' \
                          -InstallArgs '${_install_options}' \
                          ${_move_dll_workaround}",
    path    => $::path,
    require => [
      Puppet_agent_upgrade_error['puppet_agent_upgrade_failure.log'],
      File["${_installps1}"]
    ]
  }

  # PUP-5480/PE-15037 Cache dir loses inheritable SYSTEM perms
  exec { 'fix inheritable SYSTEM perms':
    command => "${::system32}\\icacls.exe \"${::puppet_client_datadir}\" /grant \"SYSTEM:(OI)(CI)(F)\"",
    unless  => "${::system32}\\cmd.exe /c ${::system32}\\icacls.exe \"${::puppet_client_datadir}\" | findstr \"SYSTEM:(OI)(CI)(F)\"",
    require => Exec['install_puppet.ps1'],
  }
}
