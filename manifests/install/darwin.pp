# @summary Manage the install process for Darwin OSes specifically.
# Private class called from puppet_agent class.
#
# @param package_version
#   The puppet-agent version to install.
# @param install_options
#   An array of additional options to pass when installing puppet-agent. Each option in
#   the array can either be a string or a hash. Each option will automatically be quoted
#   when passed to the install command. With Windows packages, note that file paths in an
#   install option must use backslashes. (Since install options are passed directly to
#   the installation command, forward slashes won't be automatically converted like they
#   are in `file` resources.) Note also that backslashes in double-quoted strings _must_
#   be escaped and backslashes in single-quoted strings _can_ be escaped.
class puppet_agent::install::darwin (
  String                       $package_version,
  Array[Variant[String, Hash]] $install_options = [],
) {
  assert_private()
  $install_script = 'osx_install.sh.erb'

  $_logfile = "${facts['env_temp_variable']}/osx_install.log"
  notice("Puppet install log file at ${_logfile}")

  $_installsh = "${facts['env_temp_variable']}/osx_install.sh"
  file { $_installsh:
    ensure  => file,
    mode    => '0755',
    content => template('puppet_agent/do_install.sh.erb'),
  }
  -> exec { 'osx_install script':
    command => "${_installsh} ${facts['puppet_agent_pid']} 2>&1 > ${_logfile} &",
  }
}
