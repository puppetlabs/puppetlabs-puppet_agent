# == Class agent_upgrade::params
#
# This class is meant to be called from agent_upgrade.
# It sets variables according to platform.
#
class agent_upgrade::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'agent_upgrade'
      $service_name = 'agent_upgrade'
    }
    'RedHat', 'Amazon': {
      $package_name = 'agent_upgrade'
      $service_name = 'agent_upgrade'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
