class puppet_agent::osfamily::windows(
  $package_file_name = undef,
) {
  assert_private()

  if !empty($package_file_name) and $::puppet_agent::is_pe == true {
    class { 'puppet_agent::prepare::package':
      package_file_name => $package_file_name,
    }
    contain puppet_agent::prepare::package
  }
}
