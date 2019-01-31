class puppet_agent::osfamily::darwin(
  $package_file_name = undef,
) {
  assert_private()

  if $::macosx_productversion_major !~ /^10\.(12|13)/ {
    fail("${::macosx_productname} ${::maxosx_productversion_major} not supported")
  }

  if $::puppet_agent::is_pe != true {
    fail("${::macosx_productname} upgrades are only supported on Puppet Enterprise")
  }

  class { 'puppet_agent::prepare::package':
    package_file_name => $package_file_name,
  }
  contain puppet_agent::prepare::package
}
