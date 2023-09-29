# @summary Manage the install process for SUSE OSes specifically.
# Private class called from puppet_agent class.
#
# @param package_version
#   The puppet-agent version to install.
# @param install_options
#   An array of additional options to pass when installing puppet-agent.
#   Each option in the array can either be a string or a hash.
#   Each option will automatically be quoted when passed to the install command.
#   With Windows packages, note that file paths in an install option must use
#   backslashes. (Since install options are passed directly to the installation
#   command, forward slashes won't be automatically converted like they are in
#   `file` resources.) Note also that backslashes in double-quoted strings
#   _must_ be escaped and backslashes in single-quoted strings _can_ be escaped.
class puppet_agent::install::suse (
  String                       $package_version,
  Array[Variant[String, Hash]] $install_options = [],
) {
  assert_private()

  if ($puppet_agent::absolute_source) or ($facts['os']['release']['major'] == '11' and $puppet_agent::is_pe) {
    $_provider = 'rpm'
    $_source = "${puppet_agent::params::local_packages_dir}/${puppet_agent::prepare::package::package_file_name}"

    exec { 'GPG check the RPM file':
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command   => "rpm -K ${_source}",
      require   => File[$_source],
      logoutput => 'on_failure',
      notify    => Package[$puppet_agent::package_name],
    }
  } else {
    $_provider = 'zypper'
    $_source = undef
  }

  $_aio_package_version = $package_version.match(/^\d+\.\d+\.\d+(\.\d+)?|^latest$|^present$/)[0]
  package { $puppet_agent::package_name:
    ensure          => $package_version,
    install_options => $install_options,
    provider        => $_provider,
    source          => $_source,
    notify          => Puppet_agent_end_run[$_aio_package_version],
  }
  puppet_agent_end_run { $_aio_package_version : }
}
