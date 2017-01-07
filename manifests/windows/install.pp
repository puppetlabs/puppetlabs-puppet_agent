# == Class puppet_agent::windows::install
#
# Private class called from puppet_agent class
#
# Manage the install process for windows specifically
#
class puppet_agent::windows::install(
  $package_file_name,
  $source                = $::puppet_agent::source,
  $install_dir           = undef,
  $install_options       = [],
  $msi_move_locked_files = $::puppet_agent::msi_move_locked_files,
  ) {
  assert_private()

  if $::puppet_agent::is_pe {
    $_agent_version = $puppet_agent::params::master_agent_version
    $_pe_server_version = pe_build_version()
    $_https_source = "https://pm.puppetlabs.com/puppet-agent/${_pe_server_version}/${_agent_version}/repos/windows/${package_file_name}"
  }
  else {
    $_https_source = "https://downloads.puppetlabs.com/windows/${package_file_name}"
  }

  $_source = $source ? {
    undef          => $_https_source,
    /^[a-zA-Z]:/ => windows_native_path($source),
    default        => $source,
  }

  $_msi_location = $_source ? {
    /^puppet:/ => windows_native_path("${::env_temp_variable}/puppet-agent.msi"),
    default    => $_source,
  }

  $_installbat = windows_native_path("${::env_temp_variable}/install_puppet.bat")
  if $_source =~ /^puppet:/ {
    file{ $_msi_location:
      source => $_source,
      before => File["${_installbat}"],
    }
  }

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
  notice ("Puppet upgrade log file at ${_logfile}")
  debug ("Installing puppet from ${_msi_location}")
  file { "${_installbat}":
    ensure  => file,
    content => template('puppet_agent/install_puppet.bat.erb')
  }->
  exec { 'install_puppet.bat':
    command => "${::system32}\\cmd.exe /c start /b ${_cmd_location} /c \"${_installbat}\" ${::puppet_agent_pid}",
    path    => $::path,
  }

  # PUP-5480/PE-15037 Cache dir loses inheritable SYSTEM perms
  exec { 'fix inheritable SYSTEM perms':
    command => "${::system32}\\icacls.exe \"${::puppet_client_datadir}\" /grant \"SYSTEM:(OI)(CI)(F)\"",
    unless  => "${::system32}\\icacls.exe \"${::puppet_client_datadir}\" | findstr \"SYSTEM:(OI)(CI)(F)\"",
    require => Exec['install_puppet.bat'],
  }
}
