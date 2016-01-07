# == Class puppet_agent::windows::install
#
# Private class called from puppet_agent class
#
# Manage the install process for windows specifically
#
class puppet_agent::windows::install {
  assert_private()

  $_arch = $::kernelmajversion ?{
    /^5\.\d+/ => 'x86', # x64 is never allowed on windows 2003
    default   => $::puppet_agent::arch
  }

  if $::puppet_agent::is_pe {
    $_agent_version = $puppet_agent::params::master_agent_version
    $_pe_server_version = pe_build_version()
    $_https_source = "https://pm.puppetlabs.com/puppet-agent/${_pe_server_version}/${_agent_version}/repos/windows/puppet-agent-${_arch}.msi"
  }
  else {
    $_https_source = "https://downloads.puppetlabs.com/windows/puppet-agent-${_arch}-latest.msi"
  }

  $_source = $::puppet_agent::source ? {
    undef          => $_https_source,
    /^[a-zA-Z]:/ => windows_native_path($::puppet_agent::source),
    default        => $::puppet_agent::source,
  }

  $_msi_location = $_source ? {
    /^puppet:/ => "${::env_temp_variable}/puppet-agent.msi",
    default    => $_source,
  }

  if $_source =~ /^puppet:/ {
    file{ $_msi_location:
      source => $_source,
      before => File["${::env_temp_variable}/install_puppet.bat"],
    }
  }

  $_cmd_location = $::rubyplatform ? {
    /i386/  => 'C:\\Windows\\system32\\cmd.exe',
    default => "${::system32}\\cmd.exe"
  }

  $_timestamp = strftime('%Y_%m_%d-%H_%M')
  $_logfile = "${::env_temp_variable}\\puppet-${_timestamp}-installer.log"
  notice ("Puppet upgrade log file at ${_logfile}")
  debug ("Installing puppet from ${_msi_location}")
  file { "${::env_temp_variable}/install_puppet.bat":
    ensure  => file,
    content => template('puppet_agent/install_puppet.bat.erb')
  }->
  exec { 'install_puppet.bat':
    command => "${::system32}\\cmd.exe /c start /b ${_cmd_location} /c \"${::env_temp_variable}\\install_puppet.bat\"",
    path    => $::path,
  }
}
