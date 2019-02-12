# == Class puppet_agent::prepare
#
# This class is called from puppet_agent to prepare for the upgrade.
#
# === Parameters
#
# [version]
#   The puppet-agent version to install.
#
class puppet_agent::prepare(
  $package_version = undef,
){
  include puppet_agent::params
  $_windows_client = downcase($::osfamily) == 'windows'

  # Manage /opt/puppetlabs for platforms. This is done before both config and prepare because,
  # on Windows, both can be in C:/ProgramData/Puppet Labs; doing it later creates a dependency
  # cycle.
  if !defined(File[$::puppet_agent::params::local_puppet_dir]) {
    file { $::puppet_agent::params::local_puppet_dir:
      ensure => directory,
    }
  }

  $_osfamily_class = downcase("::puppet_agent::osfamily::${::osfamily}")

  # Manage deprecating configuration settings.
  class { 'puppet_agent::prepare::puppet_config':
    package_version => $package_version,
    before          => Class[$_osfamily_class],
  }
  contain puppet_agent::prepare::puppet_config

  # PLATFORM SPECIFIC CONFIGURATION
  # Break out the platform-specific configuration into subclasses, dependent on
  # the osfamily of the client being configured.

  case $::osfamily {
    'redhat', 'debian', 'windows', 'solaris', 'aix', 'suse', 'darwin': {
      contain $_osfamily_class
    }
    default: {
      fail("puppet_agent not supported on ${::osfamily}")
    }
  }
}
