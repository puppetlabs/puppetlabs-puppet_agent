# == Class puppet_agent::install::default
#
# Private class called from puppet_agent::install class
#
# Manage the install process for systems using their default package provider
#
class puppet_agent::install::default (
  $version
) {
  assert_private()

  if $version == undef {
    $version = 'present'
  }

  package { $::puppet_agent::package_name:
    ensure => $version,
  }
}
