# == Class puppet_agent::prepare
#
# This class is called from puppet_agent to prepare for the upgrade.
#
# === Parameters
#
# [package_file_name]
#   The file name, with platform and version, of the puppet-agent package to be
#   downloaded and installed.  Older systems and package managers may require
#   us to manually download the puppet-agent package.
# [version]
#   The puppet-agent version to install.
# [service_names]
#   A list of services we expect to manage after upgrade.
# [old_service_names]
#   A list of services that should be halted before upgrade.
#
class puppet_agent::prepare(
  $package_file_name = undef,
  $package_version = undef,
  $service_names = [],
  $old_service_names = [],
){
  include puppet_agent::params
  $_windows_client = downcase($::osfamily) == 'windows'
  if $_windows_client {

    File{
      source_permissions => ignore,
    }
  }
  else  {
    File {
      source_permissions => use,
    }
  }

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

  if versioncmp("${::clientversion}", '4.0.0') < 0 {
    # Migrate old files; assumes user Puppet runs under won't change during upgrade
    # We assume the current Puppet settings are authoritative; if anything exists
    # in the destination but not the source, it'll be overwritten.
    file { $::puppet_agent::params::puppetdirs:
      ensure => directory,
    }

    if !$_windows_client { #Windows didn't change only nix systems
      class { 'puppet_agent::prepare::ssl':
        before => Class[$_osfamily_class],
      }
      contain puppet_agent::prepare::ssl

    # manage client.cfg and server.cfg contents
      file { $::puppet_agent::params::mcodirs:
        ensure => directory,
      }

      # The mco_*_config facts will return the location of mcollective config (or nil), prefering PE over FOSS.
      if $::mco_server_config {
        class { 'puppet_agent::prepare::mco_server_config':
          before => Class[$_osfamily_class],
        }
        contain puppet_agent::prepare::mco_server_config
      }
      if $::mco_client_config {
        class { 'puppet_agent::prepare::mco_client_config':
          before => Class[$_osfamily_class],
        }
        contain puppet_agent::prepare::mco_client_config
      }
    }
  }

  # Ensure services are stopped before upgrading. In some systems, the old service is not stopped before upgrading, and
  # when the new service is configured differently this can leave an orphaned service running.
  # Upgrades from 4.0 should cleanly restart services. Only ensure services are stopped when upgrading from 3.x.
  if (versioncmp("${::clientversion}", '4.0.0') < 0) {
    $stop_params = {
      ensure => 'stopped',
      enable => false,
    }
    $old_service_names.each |$service| {
      if member($service_names, $service) {
        # Service will be managed after install, use puppetlabs-transition.
        notify { "disable ${service} notice":
          message => "using puppetlabs-transition to stop/disable ${service} prior to upgrade",
        }
        transition { "stop ${service}":
          resource   => Service[$service],
          attributes => $stop_params,
          prior_to   => Notify["disable ${service} notice"],
        }
      } else {
        service { "stop ${service}":
          * => $stop_params,
        }
      }
    }
  }

  # PLATFORM SPECIFIC CONFIGURATION
  # Break out the platform-specific configuration into subclasses, dependent on
  # the osfamily of the client being configured.

  case $::osfamily {
    'redhat', 'debian', 'windows', 'solaris', 'aix', 'suse', 'darwin': {
      class { $_osfamily_class:
        package_file_name => $package_file_name,
      }
      contain $_osfamily_class
    }
    default: {
      fail("puppet_agent not supported on ${::osfamily}")
    }
  }
}
