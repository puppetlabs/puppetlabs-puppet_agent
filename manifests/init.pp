# == Class: agent_upgrade
#
# Full description of class agent_upgrade here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class agent_upgrade (
  $package_name = $::agent_upgrade::params::package_name,
  $service_name = $::agent_upgrade::params::service_name,
) inherits ::agent_upgrade::params {

  # validate parameters here

  class { '::agent_upgrade::install': } ->
  class { '::agent_upgrade::config': } ~>
  class { '::agent_upgrade::service': } ->
  Class['::agent_upgrade']
}
