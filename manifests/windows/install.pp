# == Class puppet_agent::install::windows
#
# Private class called from puppet_agent::install class
#
# Manage the install process for windows specifically
#
class puppet_agent::install::windows (
  $version
) {
  assert_private()

  $_arch = $::kernelmajversion ?{
    /^5\.\d+/ => 'x86', # x64 is never allowed on windows 2003
    default   => $::puppet_agent::arch
  }

  # If version is undefined and not at Puppet 4, upgrade to latest.
  # Otherwise only perform an upgrade if version declares a version different from the current one.
  if ($version == undef and versioncmp("${::clientversion}", '4.0.0') < 0) or ($version != undef and versioncmp("${::clientversion}", $version) != 0) {
    if $::puppet_agent::is_pe {
      $_agent_version = chomp(file('/opt/puppetlabs/puppet/VERSION'))
      $_pe_server_version = pe_build_version()
      $_https_source = "https://pm.puppetlabs.com/puppet-agent/${_pe_server_version}/${_agent_version}/repos/windows/puppet-agent-${_arch}.msi"
    }
    elsif $version == undef {
      $_https_source = "https://downloads.puppetlabs.com/windows/puppet-agent-${_arch}-latest.msi"
    }
    else {
      $_https_source = "https://downloads.puppetlabs.com/windows/puppet-agent-${version}-${_arch}.msi"
    }

    $_source = $::puppet_agent::source ? {
      undef          => $_https_source,
      /^[a-zA-Z]:/ => windows_native_path($::puppet_agent::source),
      default        => $::puppet_agent::source,
    }

    $_msi_location = $_source ? {
      /^puppet:/ => "${::env_temp_variable}\\puppet-agent.msi",
      default    => $_source,
    }

    if $_source =~ /^puppet:/ {
      file{ $_msi_location:
        source => $_source,
        before => File["${::env_temp_variable}\\install_puppet.bat"],
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
    file { "${::env_temp_variable}\\install_puppet.bat":
      ensure  => file,
      content => template('puppet_agent/install_puppet.bat.erb')
    }->
    exec { 'install_puppet.bat':
      command => "${::system32}\\cmd.exe /c start /b ${_cmd_location} /c \"${::env_temp_variable}\\install_puppet.bat\"",
      path    => $::path,
    }
  }
}
