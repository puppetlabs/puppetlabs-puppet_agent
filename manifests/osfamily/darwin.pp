class puppet_agent::osfamily::darwin(
  $package_file_name = undef,
) {
  assert_private()

  if $::macosx_productversion_major !~ '10\.[9,10,11]' {
    fail("${::macosx_productname} ${::maxosx_productversion_major} not supported")
  }

  class { 'puppet_agent::prepare::package':
    package_file_name => $package_file_name,
  }
  contain puppet_agent::prepare::package
}
