# == Class puppet_agent::windows::install
#
# Private class called from puppet_agent class
#
# Manage the install process for windows specifically
#
class puppet_agent::windows::install(
  $package_file_name,
  $install_dir           = undef,
  $install_options       = [],
  $msi_move_locked_files = $::puppet_agent::msi_move_locked_files,
  ) {
  assert_private()

  $_install_options = $install_options ? {
    []      => ['REINSTALLMODE="amus"'],
    default => $install_options
  }

  $_installbat = windows_native_path("${::env_temp_variable}/install_puppet.bat")
  $_msi_location = $package_file_name

  $_cmd_location = $::rubyplatform ? {
    /i386/  => 'C:\\Windows\\system32\\cmd.exe',
    default => "${::system32}\\cmd.exe"
  }

  if (member($::puppet_agent::service_names, 'puppet')) {
    $_agent_startup_mode = 'Automatic'
  } else {
    $_agent_startup_mode = undef
  }

  $_timestamp = strftime('%Y_%m_%d-%H_%M')
  $_logfile = windows_native_path("${::env_temp_variable}/puppet-${_timestamp}-installer.log")
  $_puppet_master = $::puppet_master_server

  debug ("Installing/Upgrading Puppet Agent via: ${package_file_name}")
  notice ("Puppet Agent MSI installer log file: ${_logfile}")

  file { "${_installbat}":
    ensure  => file,
    content => template('puppet_agent/install_puppet.bat.erb')
  }
  -> exec { 'install_puppet.bat':
    command => "${::system32}\\cmd.exe /c start /b ${_cmd_location} /c \"${_installbat}\" ${::puppet_agent_pid}",
    path    => $::path,
  }

  # PUP-5480/PE-15037 Cache dir loses inheritable SYSTEM perms
  exec { 'Reset inheritable SYSTEM permissions after MSIEXEC':
    command => "${::system32}\\icacls.exe \"${::puppet_client_datadir}\" /grant \"SYSTEM:(OI)(CI)(F)\"",
    unless  => "${::system32}\\icacls.exe \"${::puppet_client_datadir}\" | findstr \"SYSTEM:(OI)(CI)(F)\"",
    require => Exec['install_puppet.bat'],
  }
}
