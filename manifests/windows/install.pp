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

  $service_names         = $::puppet_agent::service_names

  if $::puppet_agent::is_pe {
    $_agent_version = $puppet_agent::params::master_agent_version
    $_pe_server_version = pe_build_version()
    $_https_source = "https://pm.puppetlabs.com/puppet-agent/${_pe_server_version}/${_agent_version}/repos/windows/${package_file_name}"
  }
  else {
    $dir = $package_file_name ? {
      /puppet-agent-5\..*/ => 'puppet5/',
      /puppet-agent-6\..*/ => 'puppet6/',
      default => ''
    }
    $_https_source = "https://downloads.puppetlabs.com/windows/${dir}${package_file_name}"
  }

  $_installps1 = windows_native_path("${::env_temp_variable}/install_puppet.ps1")

  $_source = $source ? {
    undef          => $_https_source,
    /^[a-zA-Z]:/ => windows_native_path($source),
    default        => $source,
  }
  $_msi_location = $_source ? {
    /^puppet:/ => windows_native_path("${::env_temp_variable}/puppet-agent.msi"),
    default    => $_source,
  }
  if $_source =~ /^puppet:/ {
    file{ $_msi_location:
      source => $_source,
      before => File["${_installps1}"],
    }
  }

  $_install_options = $install_options ? {
    []      => windows_msi_installargs(['REINSTALLMODE="amus"']),
    default => windows_msi_installargs($install_options)
  }

  if (member($::puppet_agent::service_names, 'puppet')) {
    $_agent_startup_mode = 'Automatic'
  } else {
    $_agent_startup_mode = undef
  }

  if $msi_move_locked_files {
    $_move_dll_workaround = '$true'
  } else {
    $_move_dll_workaround = '$false'
  }

  $_timestamp = strftime('%Y_%m_%d-%H_%M')
  $_logfile = windows_native_path("${::env_temp_variable}/puppet-${_timestamp}-installer.log")
  $_puppet_master = $::puppet_master_server
  $_install_pid_file_loc = windows_native_path("${::env_temp_variable}/puppet_agent_install.pid")

  notice ("Puppet upgrade log file at ${_logfile}")
  debug ("Installing puppet from ${_msi_location}")

  file { "${_installps1}":
    ensure  => file,
    content => template('puppet_agent/install_puppet.ps1.erb')
  }
  -> exec { 'install_puppet.ps1':
    command => "${::system32}\\cmd.exe /c start /b ${::system32}\\WindowsPowerShell\\v1.0\\powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -NonInteractive -File ${_installps1} ${::puppet_agent_pid}",
    path    => $::path,
  }

  # PUP-5480/PE-15037 Cache dir loses inheritable SYSTEM perms
  exec { 'fix inheritable SYSTEM perms':
    command => "${::system32}\\icacls.exe \"${::puppet_client_datadir}\" /grant \"SYSTEM:(OI)(CI)(F)\"",
    unless  => "${::system32}\\cmd.exe /c ${::system32}\\icacls.exe \"${::puppet_client_datadir}\" | findstr \"SYSTEM:(OI)(CI)(F)\"",
    require => Exec['install_puppet.ps1'],
  }
}
