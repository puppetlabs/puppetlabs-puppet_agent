# == Class agent_upgrade::install
#
# This class is called from agent_upgrade for install.
#
class agent_upgrade::install {

  package { $::agent_upgrade::package_name:
    ensure => present,
  }
}
