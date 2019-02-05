class puppet_agent::osfamily::darwin{
  assert_private()

  if $::macosx_productversion_major !~ /^10\.(12|13)/ {
    fail("${::macosx_productname} ${::maxosx_productversion_major} not supported")
  }

  if $::puppet_agent::is_pe != true {
    fail("${::macosx_productname} upgrades are only supported on Puppet Enterprise")
  }

  if $::puppet_agent::is_pe {
    $pe_server_version = pe_build_version()
    $source = "puppet:///pe_packages/${pe_server_version}/${::platform_tag}/${puppet_agent::package_name}-${puppet_agent::package_version}-1.osx${$::macosx_productversion_major}.dmg"
  } else {
    $source = "https://downloads.puppet.com/mac/${::puppet_agent::collection}/${::macosx_productversion_major}/${::puppet_agent::arch}/${puppet_agent::package_name}-${puppet_agent::package_version}-1.osx${$::macosx_productversion_major}.dmg"
  }

  class { '::puppet_agent::prepare::package':
    source => $source,
  }

  contain puppet_agent::prepare::package
}
