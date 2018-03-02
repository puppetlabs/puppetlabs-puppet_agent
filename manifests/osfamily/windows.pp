class puppet_agent::osfamily::windows(
  $package_file_name = undef,
  $package_version   = undef,
  $source            = undef,
) {
  assert_private()

  if !empty($package_file_name) {
    class { 'puppet_agent::prepare::package':
      package_file_name => $package_file_name,
      package_version   => $package_version,
      source            => $source,
    }
    contain puppet_agent::prepare::package
  }
}
