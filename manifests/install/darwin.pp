# == Class puppet_agent::install::darwin
#
# Private class called from puppet_agent class
#
# Manage the install process for Darwin OSes specifically
#
class puppet_agent::install::darwin(
  $package_version,
  $install_options = [],
){
  assert_private()
  $install_script = 'osx_install.sh.erb'

  $_logfile = "${::env_temp_variable}/osx_install.log"
  notice("Puppet install log file at ${_logfile}")

  $_installsh = "${::env_temp_variable}/osx_install.sh"
  file { "${_installsh}":
    ensure  => file,
    mode    => '0755',
    content => template('puppet_agent/do_install.sh.erb')
  }
  -> exec { 'osx_install script':
    command => "${_installsh} ${::puppet_agent_pid} 2>&1 > ${_logfile} &",
  }
}
