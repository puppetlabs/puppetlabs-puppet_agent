# == Class puppet_agent::install::solaris
#
# Private class called from puppet_agent class
#
# Manage the install process for solaris specifically
#
class puppet_agent::install::solaris(
  $package_version,
  $install_options = [],
){
  assert_private()
  if $::operatingsystemmajrelease == '10' {
    $_unzipped_package_name = regsubst($::puppet_agent::prepare::package::package_file_name, '\.gz$', '')
    $install_script = 'solaris_install.sh.erb'

    # The following are expected to be available in the solaris_install.sh.erb template:
    $adminfile = '/opt/puppetlabs/packages/solaris-noask'
    $sourcefile = "/opt/puppetlabs/packages/${_unzipped_package_name}"
    # Starting with puppet6 collections we no longer carry the mcollective service
    if $::puppet_agent::collection != 'PC1' and $::puppet_agent::collection != 'puppet5' {
      $service_names = delete($::puppet_agent::service_names, 'mcollective')
    } else {
      $service_names = $::puppet_agent::service_names
    }

    # Puppet prior to 5.0 would not use a separate process contract when forking from the Puppet
    # service. That resulted in service-initiated upgrades failing because trying to remove or
    # upgrade the package would stop the service, thereby killing the Puppet run. Use a script
    # to perform the upgrade after Puppet is done running.
    # Puppet 5.0 adds this, but some i18n implementation is loading code fairly late and appears
    # to be messing up the upgrade.

    if $::puppet_agent::aio_upgrade_required {
      $_logfile = "${::env_temp_variable}/solaris_install.log"
      notice ("Puppet install log file at ${_logfile}")

      $_installsh = "${::env_temp_variable}/solaris_install.sh"
      file { "${_installsh}":
        ensure  => file,
        mode    => '0755',
        content => template('puppet_agent/do_install.sh.erb')
      }
      -> exec { 'solaris_install script':
        command => "/usr/bin/ctrun -l none ${_installsh} ${::puppet_agent_pid} 2>&1 > ${_logfile} &",
      }
    }
  } else {
    package { $::puppet_agent::package_name:
      ensure          => $package_version,
      install_options => $install_options,
    }
  }
}
