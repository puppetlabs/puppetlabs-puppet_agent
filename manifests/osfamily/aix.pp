class puppet_agent::osfamily::aix(
  $package_file_name = undef,
) {
  assert_private()

  if $::operatingsystem != 'AIX' {
    fail("${::operatingsystem} not supported")
  }

  if $::puppet_agent::is_pe != true {
    fail('AIX upgrades are only supported on Puppet Enterprise')
  }

  class { 'puppet_agent::prepare::package':
    package_file_name => $package_file_name,
  }

  contain puppet_agent::prepare::package
}
