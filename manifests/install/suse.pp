# == Class puppet_agent::install::suse
#
# Private class called from puppet_agent class
#
# Manage the install process for SUSE OSes specifically
#
class puppet_agent::install::suse(
  $package_version,
  $install_options = [],
){
  assert_private()

  if ($::puppet_agent::absolute_source) or ($::operatingsystemmajrelease == '11' and $::puppet_agent::is_pe) {
    $_provider = 'rpm'
    $_source = "${::puppet_agent::params::local_packages_dir}/${::puppet_agent::prepare::package::package_file_name}"

    exec { 'GPG check the RPM file':
      path      => '/bin:/usr/bin:/sbin:/usr/sbin',
      command   => "rpm -K ${_source}",
      require   => File[$_source],
      logoutput => 'on_failure',
      notify    => Package[$::puppet_agent::package_name],
    }
  } else {
    $_provider = 'zypper'
    $_source = undef
  }

  $_aio_package_version = $package_version.match(/^\d+\.\d+\.\d+(\.\d+)?/)[0]
  package { $::puppet_agent::package_name:
    ensure          => $package_version,
    install_options => $install_options,
    provider        => $_provider,
    source          => $_source,
    notify          => Puppet_agent_end_run[$_aio_package_version],
  }
  puppet_agent_end_run { $_aio_package_version : }
}
