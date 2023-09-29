# @summary Manage the install process for Solaris OSes specifically.
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
class puppet_agent::install::solaris (
  String                       $package_version,
  Array[Variant[String, Hash]] $install_options = [],
) {
  assert_private()
  if $facts['os']['release']['major'] == '10' {
    $_unzipped_package_name = regsubst($puppet_agent::prepare::package::package_file_name, '\.gz$', '')
    $install_script = 'solaris_install.sh.erb'

    # The following are expected to be available in the solaris_install.sh.erb template:
    $adminfile = '/opt/puppetlabs/packages/solaris-noask'
    $sourcefile = "/opt/puppetlabs/packages/${_unzipped_package_name}"

    $service_names = $puppet_agent::service_names

    # Puppet prior to 5.0 would not use a separate process contract when forking from the Puppet
    # service. That resulted in service-initiated upgrades failing because trying to remove or
    # upgrade the package would stop the service, thereby killing the Puppet run. Use a script
    # to perform the upgrade after Puppet is done running.
    # Puppet 5.0 adds this, but some i18n implementation is loading code fairly late and appears
    # to be messing up the upgrade.

    if $puppet_agent::aio_upgrade_required {
      $_logfile = "${facts['env_temp_variable']}/solaris_install.log"
      notice ("Puppet install log file at ${_logfile}")

      $_installsh = "${facts['env_temp_variable']}/solaris_install.sh"
      file { $_installsh:
        ensure  => file,
        mode    => '0755',
        content => template('puppet_agent/do_install.sh.erb'),
      }
      -> exec { 'solaris_install script':
        command => "/usr/bin/ctrun -l none ${_installsh} ${facts['puppet_agent_pid']} 2>&1 > ${_logfile} &",
      }
    }
  } else {
    $_aio_package_version = $package_version.match(/^\d+\.\d+\.\d+(\.\d+)?/)[0]
    package { $puppet_agent::package_name:
      ensure          => $package_version,
      install_options => $install_options,
      notify          => Puppet_agent_end_run[$_aio_package_version],
    }
    puppet_agent_end_run { $_aio_package_version : }
  }
}
