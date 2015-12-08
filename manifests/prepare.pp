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
#
class puppet_agent::prepare(
  $package_file_name = undef,
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

  # Migrate old files; assumes user Puppet runs under won't change during upgrade
  # We assume the current Puppet settings are authoritative; if anything exists
  # in the destination but not the source, it'll be overwritten.
  file { $::puppet_agent::params::puppetdirs:
    ensure => directory,
  }
  include puppet_agent::prepare::puppet_config

  if !$_windows_client { #Windows didn't change only nix systems
    include puppet_agent::prepare::ssl

  # manage client.cfg and server.cfg contents
    file { $::puppet_agent::params::mcodirs:
      ensure => directory,
    }

    # The mco_*_config facts will return the location of mcollective config (or nil), prefering PE over FOSS.
    if $::mco_server_config {
      include puppet_agent::prepare::mco_server_config
    }
    if $::mco_client_config {
      include puppet_agent::prepare::mco_client_config
    }
  }

  # PLATFORM SPECIFIC CONFIGURATION
  # Break out the platform-specific configuration into subclasses, dependent on
  # the osfamily of the client being configured.

  case $::osfamily {
    'redhat', 'debian', 'windows', 'solaris', 'aix', 'suse', 'darwin': {
      $_osfamily_class = downcase("::puppet_agent::osfamily::${::osfamily}")
      class { $_osfamily_class:
        package_file_name => $package_file_name
      }
      contain $_osfamily_class
    }
    default: {
      fail("puppet_agent not supported on ${::osfamily}")
    }
  }
}
