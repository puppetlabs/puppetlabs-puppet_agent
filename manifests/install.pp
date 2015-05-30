# == Class puppet_agent::install
#
# This class is called from puppet_agent for install.
#
class puppet_agent::install {

  package { $::puppet_agent::package_name:
    ensure => present,
  }
}
