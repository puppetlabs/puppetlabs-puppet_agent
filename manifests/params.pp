# == Class agent_upgrade::params
#
# This class is meant to be called from agent_upgrade.
# It sets variables according to platform.
#
class agent_upgrade::params {
  case $::osfamily {
    # TODO: Add Debian, Windows
    'RedHat', 'Amazon': {
      $package_name = 'puppet-agent'
      $service_names = ['puppet', 'mcollective']
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
