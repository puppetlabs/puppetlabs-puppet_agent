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

  if versioncmp("$::clientversion", '3.8.0') < 0 {
    fail('upgrading requires Puppet 3.8')
  }
  elsif versioncmp("$::clientversion", '4.0.0') >= 0 {
    info('agent_upgrade performs no actions on Puppet 4+')
  }
  else {
    class { '::agent_upgrade::prepare': } ->
    class { '::agent_upgrade::install': } ->
    class { '::agent_upgrade::config': } ~>
    class { '::agent_upgrade::service': }

    contain '::agent_upgrade::prepare'
    contain '::agent_upgrade::install'
    contain '::agent_upgrade::config'
    contain '::agent_upgrade::service'
  }
}
