# == Class: agent_upgrade
#
# Upgrades Puppet 3.8 to Puppet 4+ (Puppet-Agent from Puppet Collection 1).
# Makes the upgrade easier by migrating SSL certs and config files to the new
# Puppet-Agent paths and removing deprecated settings that are no longer
# supported by Puppet 4.
#
# === Parameters
#
# [package_name]
#   The package to upgrade to, i.e. `puppet-agent`.
# [service_names]
#   An array of services to start, normally `puppet` and `mcollective`.
#   None will be started if the array is empty.
#
class agent_upgrade (
  $package_name = $::agent_upgrade::params::package_name,
  $service_names = $::agent_upgrade::params::service_names,
) inherits ::agent_upgrade::params {

  # check puppet version: if < 3.8, fail; elif >= 4.0, warn and stop; else proceed
  if versioncmp("$::clientversion", '3.8.0' ) < 0 {
    fail('upgrading requires Puppet 3.8')
  }
  elsif versioncmp("$::clientversion", '4.0.0') >= 0 {
    warning('Puppet 4+ already installed, nothing to do')
  }
  else {
    class { '::agent_upgrade::prepare': } ~>
    class { '::agent_upgrade::install': } ~>
    class { '::agent_upgrade::config': } ~>
    class { '::agent_upgrade::service': } ~>
    Class['::agent_upgrade']
  }
}
