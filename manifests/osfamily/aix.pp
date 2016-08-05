class puppet_agent::osfamily::aix(
  $package_file_name = undef,
) {
  assert_private()

  class { 'puppet_agent::prepare::package':
    package_file_name => $package_file_name,
  }

  contain puppet_agent::prepare::package
}
