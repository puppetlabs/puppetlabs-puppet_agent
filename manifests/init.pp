# == Class: puppet_agent
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
class puppet_agent (
  $package_name = $::puppet_agent::params::package_name,
  $service_names = $::puppet_agent::params::service_names,
) inherits ::puppet_agent::params {

  if versioncmp("$::clientversion", '3.8.0') < 0 {
    fail('upgrading requires Puppet 3.8')
  }
  elsif versioncmp("$::clientversion", '4.0.0') >= 0 {
    info('puppet_agent performs no actions on Puppet 4+')
  }
  else {
    class { '::puppet_agent::prepare': } ->
    class { '::puppet_agent::install': } ->
    class { '::puppet_agent::config': } ~>
    class { '::puppet_agent::service': }

    contain '::puppet_agent::prepare'
    contain '::puppet_agent::install'
    contain '::puppet_agent::config'
    contain '::puppet_agent::service'
  }
}
